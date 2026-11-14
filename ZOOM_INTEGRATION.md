# البثّ المباشر عبر Zoom في Brainixa — دليل التكامل

يشرح هذا المستند كيف يعمل الاجتماع المباشر في منصّة Brainixa: في حصص الباقات، وفي
الاستشارات، وفي الحصص الأسبوعيّة. وهو موجَّه إلى من سيربط تطبيق الموبايل بهذه النقاط.

القاعدة التي بُني عليها التكامل كلّه: **لا يُسلَّم أحد رابط `zoom.us` أبدًا.** يطلب المعلّم
فتح الغرفة فيحصل على رقم اجتماع وتوقيع يقول «أنت المضيف»، ويطلب الطالب الانضمام فيحصل على
رقم الاجتماع نفسه وتوقيع يقول «أنت مشارك». ويتولّى Zoom Meeting SDK داخل التطبيق تحويل ذلك
إلى حصّة تُعرض داخل Brainixa.

---

## ١. البنية في سطور

### تطبيقان في Zoom Marketplace، ولا يتبادلان الأدوار

| التطبيق | وظيفته |
|---|---|
| **Server‑to‑Server OAuth** (`Brainixa Backend`) | الباك إند يتصرّف نيابةً عن حساب Zoom بلا مستخدم مسجَّل: يُنشئ الاجتماع، ينهيه، ويجلب `ZAK` المضيف. |
| **Meeting SDK** (`Brainixa Meeting SDK`) | توقيع الانضمام فقط. السرّ لا يغادر الخادم إطلاقًا؛ يصل التطبيق توقيع قصير العمر لا المفتاح. |

الاعتمادات في `config/zoomConfig.php`، وهو **خارج Git** عمدًا (القالب هو
`config/zoomConfig.example.php`). إن غاب الملفّ ردَّت كل نقطة Zoom بخطأ صريح:
«لم يتم ضبط تكامل Zoom على هذا الخادم بعد».

الكود:

| الملفّ | المسؤوليّة |
|---|---|
| `helpers/zoom.php` | التوكن، نداء Zoom REST، توقيع SDK، الـ ZAK، إنشاء/إنهاء الاجتماع. |
| `app/availability/zoom.php` | حصص الباقات (`teacher_availability_slots`). |
| `app/consultations/zoom.php` | الاستشارات (`consultation_slots`). |
| `app/sessions/zoom.php` | الحصص الأسبوعيّة (`class_sessions`). |

### قيد لا بدّ من معرفته قبل أي وعد

حساب Zoom الحالي هو **Zoom Workplace Pro بترخيص مضيف واحد**، والمضيف المرخَّص يستضيف اجتماعًا
واحدًا في الوقت نفسه. أي: **حصّة مباشرة واحدة على مستوى المنصّة كلّها** حتى تُشترى تراخيص
إضافيّة. محاولة فتح غرفة ثانية بالتوازي سترتدّ بخطأ من Zoom.

---

## ٢. ثلاثة مسارات، لا مسار واحد

يجري البثّ المباشر على ثلاثة جداول مختلفة، لكلٍّ منها نقاطه وفحص استحقاقه. والفارق بينها هو
**من يُسمح له بالدخول وكيف يُتحقَّق من ذلك**:

| المسار | الجدول | من يدخل؟ | يُعرَّف الاجتماع بـ |
|---|---|---|---|
| **حصص الباقات** (الأساسي) | `teacher_availability_slots` + `availability_slot_bookings` | من له صفّ حجز `booked` في هذا الموعد بالذات | `slot_id` |
| **الاستشارات** | `consultation_slots` | الطالب صاحب الحجز نفسه (علاقة ١:١) | `slot_id` |
| **الحصص الأسبوعيّة** | `class_sessions` + `session_zoom_meetings` | من لديه اشتراك فعّال يغطّي الكورس أو المادّة | `session_id` + تاريخ اليوم |

> **المسار الذي يعمل عليه الإنتاج اليوم هو الأوّل.** «مواعيد الباقات» / «مواعيدي المتاحة» هي
> حصص الباقات الحقيقيّة. أمّا `class_sessions` فقالب أسبوعي أقدم (يوم من الأسبوع + وقت، يتكرّر
> كل أسبوع)، ولذلك احتاج جدولًا منفصلًا `session_zoom_meetings` يحمل اجتماعًا لكل **تشغيلة**
> من تشغيلات الحصّة، بمفتاح فريد على `(session_id, session_date)`.

---

## ٣. دورة حياة الحصّة

ثلاث خطوات متتالية، واحدة لا تصحّ قبل التي قبلها:

```
  المعلّم: POST .../zoom/start   →  تُنشأ غرفة Zoom، ويعود توقيع المضيف + ZAK
  الطالب: GET  .../zoom/status   →  هل فُتحت الغرفة؟ (رخيصة، تصلح للاستطلاع الدوري)
  الطالب: GET  .../zoom/join     →  يُفحص الاستحقاق، ثمّ يُصدَر توقيع المشارك
  المعلّم: POST .../zoom/end     →  يُنهى الاجتماع وتُغلق الغرفة
```

### لماذا ثلاث خطوات وليس رابطًا واحدًا؟

- **التوقيع يُصكّ عند الضغط على «انضمّ»، لا قبله.** وهو قصير العمر وصالح لاجتماع واحد بعينه،
  فلا قيمة له بعد انتهاء الحصّة.
- **الدور يُقرَّر على الخادم من حقائق الخادم، لا ممّا أرسله العميل.** طالب يستطيع طلب
  `role = 1` يستطيع كتم الحصّة وطرد الحاضرين.
- **الضغط على «ابدأ» مرّتين لا يفتح غرفتين.** يُبحث عن الغرفة القائمة أوّلًا وتُعاد كما هي،
  ولا يُجدَّد إلّا التوقيع والـ ZAK لأنّهما قصيرا العمر بطبيعتهما.

### الفرق بين `signature` و `ZAK`

التوقيع وحده يسمح بالانضمام إلى اجتماع، ولا يسمح ببدئه. والـ `ZAK` هو ما يقول لـ Zoom «هذا هو
المضيف». بدونه يجلس المعلّم في غرفة انتظار حصّته. **وهو لا يُسلَّم لطالب أبدًا** — ولذلك يظهر
في استجابة `start` فقط.

---

## ٤. النقاط (Endpoints)

القاعدة: `https://camp-coding.online/brain-ixa`
الاستيثاق: `Authorization: Bearer <access_token>` لكل النقاط أدناه.

### ٤.١ حصص الباقات — المسار الأساسي

| الطريقة | المسار | من | المُدخل |
|---|---|---|---|
| `POST` | `/teacher/availability/zoom/start` | المعلّم | `{"slot_id": 123}` (أو `id`، أو `?id=`) |
| `POST` | `/teacher/availability/zoom/end` | المعلّم | `{"slot_id": 123}` |
| `GET` | `/student/availability/zoom/join?slot_id=123` | الطالب | — |
| `GET` | `/student/availability/zoom/status?slot_id=123` | الطالب | — |

ولمعرفة `slot_id` أصلًا:

| الطريقة | المسار | ماذا يعيد |
|---|---|---|
| `GET` | `/student/availability` | المواعيد المتاحة ضمن باقات الطالب |
| `GET` | `/student/availability/my-schedule` | مواعيد الطالب المحجوزة |
| `POST` | `/student/availability/book` | حجز موعد — `{"slot_id": 123}` |
| `GET` | `/teacher/availability` | مواعيد المعلّم نفسه |

### ٤.٢ الاستشارات

| الطريقة | المسار | من | المُدخل |
|---|---|---|---|
| `POST` | `/teacher/consultations/zoom/start` | المعلّم | `{"slot_id": 55}` |
| `POST` | `/teacher/consultations/zoom/end` | المعلّم | `{"slot_id": 55}` |
| `POST` | `/admin/consultations/zoom/start` | الأدمن | `{"slot_id": 55}` — الأدمن يستضيف أيّ استشارة |
| `POST` | `/admin/consultations/zoom/end` | الأدمن | `{"slot_id": 55}` |
| `GET` | `/student/consultations/zoom/join?slot_id=55` | الطالب | — |
| `GET` | `/student/consultations/zoom/status?slot_id=55` | الطالب | — |

ولمعرفة `slot_id`:

| الطريقة | المسار | ماذا يعيد |
|---|---|---|
| `GET` | `/student/consultations` | المعلّمون الذين لديهم مواعيد استشارة متاحة |
| `GET` | `/student/consultations/slots?teacher_id=…` | المواعيد المتاحة |
| `POST` | `/student/consultations/book` | حجز — `{"slot_id": 55}` فيصير `pending` |
| `GET` | `/student/consultations/my-bookings` | حجوزات الطالب بحالاتها |
| `GET` | `/teacher/consultations/bookings` | الحجوزات الواردة للمعلّم |
| `POST` | `/teacher/consultations/respond` | الاعتماد أو الرفض |

### ٤.٣ الحصص الأسبوعيّة

| الطريقة | المسار | من | المُدخل |
|---|---|---|---|
| `POST` | `/teacher/sessions/zoom/start` | المعلّم | `{"session_id": 9}` |
| `POST` | `/teacher/sessions/zoom/end` | المعلّم | `{"session_id": 9}` |
| `GET` | `/student/sessions/zoom/join?session_id=9` | الطالب | — |
| `GET` | `/student/sessions/zoom/status?session_id=9` | الطالب | — |

و `GET /student/sessions/today` يعيد حصص اليوم بمعرّفاتها.

---

## ٥. شكل الاستجابة وما يفعله التطبيق بها

كل استجابات الـ API تعود بـ **HTTP 200** حتى في حالة الخطأ؛ الحَكَم هو حقل `status` في الجسم.

### استجابة المعلّم — `zoom/start`

```json
{
  "status": "success",
  "message": "Zoom room is ready",
  "data": {
    "slot_id": 123,
    "meeting_number": "81234567890",
    "password": "a1B2c3",
    "role": 1,
    "signature": "<JWT>",
    "zak": "<ZAK>",
    "sdk_key": "andQ8D6ATQbS6uGVhpQ7g",
    "user_name": "أ. محمد",
    "user_email": "teacher1@brainixa.cloud"
  }
}
```

في مسار الحصص الأسبوعيّة يكون المفتاح `session_id` بدل `slot_id`؛ وما عدا ذلك متطابق.

### استجابة الطالب — `zoom/join`

هي نفسها، **بفارقين**: `role` تساوي `0`، ولا يوجد `zak` إطلاقًا.

### استجابة الحالة — `zoom/status`

```json
{ "status": "success", "data": { "slot_id": 123, "is_live": true } }
```

لا تحمل توقيعًا عمدًا — فهي رخيصة بما يكفي لاستطلاعها دوريًّا من شاشة الطالب، وزرّ «انضمّ» هو
الذي ينادي `join`.

### ربط الحقول بـ Zoom Meeting SDK

| الحقل | استعماله |
|---|---|
| `meeting_number` | رقم الاجتماع (`meetingNumber` / `meetingNo`). نصّ لا رقم: معرّفات Zoom تتجاوز 32‑bit. |
| `password` | كلمة مرور الاجتماع. |
| `signature` | توقيع HS256 الذي يفتح **هذا الاجتماع تحديدًا** بهذا الدور. |
| `sdk_key` | `appKey` / `sdkKey` الخاصّ بتطبيق Meeting SDK. |
| `zak` | `zoomAccessToken` عند **بدء** الاجتماع (المضيف فقط). |
| `user_name` / `user_email` | الاسم الظاهر للمشارك. |
| `role` | `1` مضيف، `0` مشارك. معلومة عرض فقط — الدور مُثبَّت داخل التوقيع. |

**ملاحظة تخصّ الموبايل تحديدًا:** حمولة التوقيع المولَّدة في
`zoom_sdk_signature()` هي `{appKey, sdkKey, mn, role, iat, exp, tokenExp}` — وهي الصيغة التي
يطلبها Web Meeting SDK. وتهيئة Meeting SDK على Android/iOS تكتفي عادةً بـ
`{appKey, iat, exp, tokenExp}`، وهذه الحمولة تحتوي عليها جميعًا وتزيد. فإن رفضها الـ SDK على
الموبايل لأي سبب، فالمطلوب تعديل بسيط على الخادم (حمولة بديلة بلا `mn`/`role`) لا إعادة بناء
للتكامل — راسلوا فريق الباك إند بالخطأ الحرفي الذي يعيده الـ SDK.

مدّة صلاحية التوقيع ساعتان افتراضيًّا (`$ttlSeconds = 7200`)، وأدنى ما يقبله Zoom ثلاثون دقيقة
وأقصاه ٤٨ ساعة.

---

## ٦. من يُسمح له بالدخول — فحص الاستحقاق

هذا هو جوهر التكامل: **Zoom لا يعلم شيئًا عمّن دفع.** القرار يُتَّخذ في الباك إند من جداول
الاشتراكات والحجوزات، وبعده فقط يُصكّ التوقيع.

| المسار | الشرط |
|---|---|
| حصص الباقات | صفّ في `availability_slot_bookings` بـ `slot_id` و `student_id` و `status = 'booked'` |
| الاستشارات | `consultation_slots.student_id` يساوي الطالب نفسه |
| الحصص الأسبوعيّة | `get_student_accessible_entities()` يُرجع `course_id` أو `subject_id` الحصّة |

والترتيب مقصود: **الاستحقاق أوّلًا، ثمّ «هل الغرفة مفتوحة»، ثمّ التوقيع** — فالطالب غير
المشترك يجب ألّا يتمكّن حتى من معرفة ما إذا كانت الحصّة جارية.

### الحقول المحجوبة عن الطالب

في قوائم المواعيد الموجَّهة إلى الطلّاب:

- `meeting_link` يُفرَّغ إلى `null` ما لم يكن الموعد `is_live`.
- `zoom_meeting_id` و `zoom_password` يُفرَّغان **دائمًا**. الانضمام يمرّ عبر
  `/student/availability/zoom/join` حصرًا، وتسليمهما في القائمة كان سيتيح لأي قادر على قراءة
  القوائم دخول الغرفة متجاوزًا الفحص.

### حقول الحالة في صفّ الموعد

| الحقل | معناه |
|---|---|
| `has_zoom` | هل أُنشئت غرفة Zoom لهذا الموعد (`zoom_meeting_id` غير فارغ) |
| `zoom_is_live` | غرفة مفتوحة الآن فعلًا، **بصرف النظر عن الساعة** |
| `is_live` | بوّابتان وأيّهما تكفي: نافذة الوقت (من ١٠ دقائق قبل البداية حتى النهاية) **أو** ضغط المعلّم «ابدأ» — و«أنهِ» يغلب عليهما معًا |
| `window_opens_at` / `window_closes_at` | حدود نافذة الوقت |

**لزرّ «ابدأ/أنهِ» في واجهة المعلّم استعملوا `zoom_is_live` لا `is_live`.** فـ `is_live`
تصير `true` بمجرّد دخول نافذة الوقت (حتى لا يُحبَس الطلّاب خارج الحصّة إن نسي المعلّم الضغط)،
واستعمالها هنا كان سيعرض «أنهِ» قبل أن توجد غرفة أصلًا.

---

## ٧. ما الذي يحدث في قاعدة البيانات

| الجدول | الدور |
|---|---|
| `zoom_oauth_tokens` | صفّ واحد. توكن S2S OAuth مخزَّنًا حتى قُبيل انتهائه بخمس دقائق — Zoom يحدّ من معدّل طلبات التوكن، وبدون هذا الصفّ كان كل فعل يستهلك واحدًا. |
| `teacher_availability_slots.zoom_meeting_id / zoom_password` | غرفة الموعد. موعد = تاريخ واحد، فلا حاجة لجدول منفصل. |
| `teacher_availability_slots.started_at / ended_at` | حالة «بدأت» المخزَّنة، وهي ما تقرؤه شاشة الطالب. |
| `consultation_slots.zoom_meeting_id / zoom_password / started_at / ended_at` | المثل تمامًا للاستشارات. |
| `session_zoom_meetings` | صفّ لكل **تشغيلة** من حصّة أسبوعيّة، بمفتاح فريد `(session_id, session_date)` يجعل الضغط المزدوج على «ابدأ» آمنًا. |

الهجرات ذات الصلة: `108`, `109` (حالة البدء/الإنهاء)، `118` (جداول Zoom للحصص الأسبوعيّة)،
`119` (أعمدة Zoom للمواعيد)، `120` (أعمدة Zoom للاستشارات).

ملاحظة: `status` في `teacher_availability_slots` و `consultation_slots` صار `VARCHAR(20)` في
الهجرتين `108`/`109`، لأنّ البدء يكتب فيه `in_progress` والإنهاء يكتب `completed` — و ENUM كان
سيبتلع القيمة التي لا يعرفها ويخزّن سلسلة فارغة بلا شكوى.

---

## ٨. حساب الاختبار الجاهز

| | |
|---|---|
| الطالب | `student2005@example.com` / `12345678` |
| المعلّم | `teacher1@brainixa.cloud` / `12345678` |
| الباقة | `package-zoom-test-2026` |

ما يحتويه الحساب:

- اشتراك فعّال في الباقة لمدّة سنة.
- ٤٣ موعدًا على مدى ١٤ يومًا (٣ يوميًّا + موعد إضافي يبدأ في الساعة الحاليّة)، **أوّل ٧ أيّام
  محجوزة للطالب** والباقي مفتوح لتجربة الحجز نفسه.
- ١٠ مواعيد استشارة: ٥ محجوزة ومعتمَدة (جاهزة ليضغط المعلّم «ابدأ»)، و٥ متاحة للحجز.
- ٧ حصص أسبوعيّة في `class_sessions`، واحدة لكل يوم، فتُوجد دائمًا «حصّة اليوم».

هذه البيانات جُهّزت على الخادم الحيّ مرّة واحدة، وحُذف ملفّ التجهيز من المستودع بعدها. المواعيد
المذكورة كانت لأسبوعين من تاريخ التجهيز (٥ نوفمبر ٢٠٢٦)، فقد تكون انقضت؛ اطلب تجهيزها من جديد عند الحاجة.

---

## ٩. سيناريو اختبار كامل

```bash
BASE=https://camp-coding.online/brain-ixa

# ١) تسجيل دخول المعلّم
TT=$(curl -s -X POST "$BASE/teacher/auth/login" -H 'Content-Type: application/json' \
     -d '{"email":"teacher1@brainixa.cloud","password":"12345678"}' | jq -r .data.tokens.access_token)

# ٢) تسجيل دخول الطالب
ST=$(curl -s -X POST "$BASE/user/student/auth/login" -H 'Content-Type: application/json' \
     -d '{"email":"student2005@example.com","password":"12345678"}' | jq -r .data.tokens.access_token)

# ٣) مواعيد الطالب المحجوزة — خذ منها slot_id
curl -s "$BASE/student/availability/my-schedule" -H "Authorization: Bearer $ST" | jq

# ٤) المعلّم يفتح الغرفة
curl -s -X POST "$BASE/teacher/availability/zoom/start" \
     -H "Authorization: Bearer $TT" -H 'Content-Type: application/json' \
     -d '{"slot_id":123}' | jq

# ٥) الطالب يسأل: هل بدأت؟
curl -s "$BASE/student/availability/zoom/status?slot_id=123" -H "Authorization: Bearer $ST" | jq

# ٦) الطالب ينضمّ
curl -s "$BASE/student/availability/zoom/join?slot_id=123" -H "Authorization: Bearer $ST" | jq

# ٧) المعلّم ينهي
curl -s -X POST "$BASE/teacher/availability/zoom/end" \
     -H "Authorization: Bearer $TT" -H 'Content-Type: application/json' \
     -d '{"slot_id":123}' | jq
```

وللاستشارات، استبدلوا `availability` بـ `consultations` وخذوا `slot_id` من
`/student/consultations/my-bookings`.

---

## ١٠. الأخطاء ومعانيها

| الرسالة | السبب | العلاج |
|---|---|---|
| `لم يتم ضبط تكامل Zoom على هذا الخادم بعد` | `config/zoomConfig.php` مفقود أو ناقص | ارفع الملفّ على الخادم (ليس في Git) |
| `أنت غير مسجل في هذا الموعد` | لا يوجد حجز `booked` للطالب في هذا الموعد | احجز أوّلًا عبر `/student/availability/book` |
| `أنت غير مشترك في هذه الحصة` | الحصّة الأسبوعيّة خارج اشتراك الطالب | تحقّق من `student_subscription_courses` |
| `الحصة لم تبدأ بعد. انتظر حتى يفتحها المعلم.` | لم يُضغط «ابدأ» بعد | هذا هو السلوك الصحيح — استطلِع `zoom/status` |
| `هذا الموعد يخص معلمًا آخر` | `slot.teacher_id` لا يطابق المعلّم المستوثَق | — |
| `تعذر فتح غرفة Zoom: …` | Zoom رفض الإنشاء — غالبًا لأنّ المضيف المرخَّص الوحيد مشغول باجتماع آخر | أنهِ الاجتماع الآخر، أو اشترِ ترخيصًا إضافيًّا |
| `تعذر الحصول على صلاحية المضيف من Zoom` | فشل جلب الـ ZAK — صلاحيّات ناقصة في تطبيق S2S | تأكّد من `user:read:zak:admin` |

**تنبيه:** إنهاء اجتماع لم ينضمّ إليه أحد يرفضه Zoom، وهذا الرفض **مُتجاهَل عمدًا** — الغرفة
تُغلق في Brainixa على كل حال، و `end` ينجح دائمًا حتى لو تعثّر `start` في منتصفه.
