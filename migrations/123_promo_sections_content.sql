-- 123_promo_sections_content.sql
--
-- Moves the home page's three marketing sections - the limited offer, the intro video and the
-- picture carousel - out of the website's code and into site_settings.
--
-- Every value below is exactly what the website is showing today: the copy was read out of
-- locales/ar.js and locales/en.js, and the media paths are the files committed under the landing
-- repo's /public/promo. Nothing about the live page changes when this runs. What changes is that
-- an admin can now edit all of it from the dashboard instead of asking for a deploy.
--
-- INSERT IGNORE, not ON DUPLICATE KEY UPDATE: a key an admin has already written is theirs, and
-- replaying this file must never overwrite their wording with the shipped wording.
--
-- Safe to run more than once.

INSERT IGNORE INTO `site_settings` (`setting_key`, `setting_value`) VALUES
  ('promo_offer_enabled', '1'),
  ('promo_offer_image', '/promo/offer.jpg'),
  ('promo_offer_badge_ar', 'عرض محدود'),
  ('promo_offer_badge_en', 'Limited offer'),
  ('promo_offer_amount_ar', '٣٠٪'),
  ('promo_offer_amount_en', '30%'),
  ('promo_offer_title_ar', 'خصم على الكورسات المباشرة'),
  ('promo_offer_title_en', 'off our live courses'),
  ('promo_offer_subtitle_ar', 'لأول ١٠٠ طالب يسجّل في المنصة. احجز مكان طفلك قبل اكتمال العدد.'),
  ('promo_offer_subtitle_en', 'For the first 100 students to register. Reserve your child''s place before it fills up.'),
  ('promo_offer_cta_ar', 'بادر بالحجز'),
  ('promo_offer_cta_en', 'Book now'),
  ('promo_offer_image_alt_ar', 'خصم ٣٠٪ على الكورسات المباشرة لأول ١٠٠ طالب يسجّل في منصة برينيكسا.'),
  ('promo_offer_image_alt_en', '30% off live courses for the first 100 students to register with Brainixa.'),
  ('promo_offer_pills', '[{"text_ar": "حصص مباشرة", "text_en": "Live classes"}, {"text_ar": "معلمون متخصصون", "text_en": "Specialist teachers"}, {"text_ar": "متابعة لتقدّم طفلك", "text_en": "Progress you can follow"}]'),
  ('promo_video_enabled', '1'),
  ('promo_video_url', '/promo/intro.mp4'),
  ('promo_video_poster', '/promo/intro-poster.jpg'),
  ('promo_video_title_ar', 'كل ما يحتاجه طفلك خلال رحلته التعليمية'),
  ('promo_video_title_en', 'Everything your child needs on their learning journey'),
  ('promo_video_subtitle_ar', 'حصص مباشرة، وكورسات مسجّلة، وكتب وتدريبات — في مكان واحد وعلى هاتفك.'),
  ('promo_video_subtitle_en', 'Live classes, recorded courses, books and exercises - in one place, on your phone.'),
  ('promo_video_cta_ar', 'ابدأ رحلتك التعليمية الآن'),
  ('promo_video_cta_en', 'Start your learning journey'),
  ('promo_video_points', '[{"text_ar": "تشمل كل المراحل التعليمية", "text_en": "Covers every school stage"}, {"text_ar": "تشمل كل المواد الدراسية", "text_en": "Covers every school subject"}, {"text_ar": "متابعة لتقدّم طفلك أولًا بأول", "text_en": "Follow your child''s progress as it happens"}]'),
  ('promo_gallery_enabled', '1'),
  ('promo_gallery_subtitle_ar', 'تعرّف علينا'),
  ('promo_gallery_subtitle_en', 'Get to know us'),
  ('promo_gallery_title_ar', 'لماذا برينيكسا؟'),
  ('promo_gallery_title_en', 'Why Brainixa?'),
  ('promo_gallery_items', '[{"image": "/promo/journey.jpg", "caption_ar": "ليس مجرّد كورس، بل رحلة تعليمية كاملة: حصص مباشرة، ومعلّمون متخصّصون، وكورسات مسجّلة، وتدريبات وأنشطة.", "caption_en": "Not just a course - a complete learning journey: live online classes, specialist teachers, recorded courses, and exercises and activities."}, {"image": "/promo/focus.jpg", "caption_ar": "نركّز على ما يحتاجه طفلك لتحقيق هدفه: نحدّد الهدف، ونبدأ من مستواه، ونساعده على التقدّم خطوة بخطوة.", "caption_en": "We focus on what your child needs to reach their goal: we set the goal, start from their level, and help them move forward step by step."}, {"image": "/promo/platform.jpg", "caption_ar": "منصّة برينيكسا: التعلّم أصبح أيسر وأقرب إلى طفلك، وكلّ ما يحتاجه في مكان واحد.", "caption_en": "The Brainixa platform: learning made easier and closer to your child, with everything they need in one place."}, {"image": "/promo/ready.jpg", "caption_ar": "منصّتنا وتطبيقنا جاهزان لاستقبال أطفالكم: إنشاء حساب، ثمّ اختيار الكورس، ثمّ بدء التعلّم.", "caption_en": "Our platform and app are ready for your children: create an account, choose a course, then start learning."}, {"image": "/promo/subjects.jpg", "caption_ar": "كلّ احتياجات طفلك التعليمية في مكان واحد: اللغة العربية، واللغة الإنجليزية، والرياضيات، والعلوم، والدراسات الاجتماعية.", "caption_en": "Every educational need in one place: Arabic, English, Maths, Science and Social Studies."}]');
