-- Supabase Billing Support Simulation: seed data
-- PART 4: the support queue (opening messages and follow-up threads)
-- Load after parts 1-3.
SET search_path = billing_sim, public;

-- Customer support requests covering billing disputes, payments, subscriptions and account questions.
INSERT INTO support_tickets (ticket_id, org_id, requester_email, requester_user_id, received_at, subject, body) VALUES
  ('TKT-7001', 'org_duret', 'camille.duret@duretstudio.example', 'u_camille', '2026-11-04 19:25:00+00', 'Cancelled my subscription, charged again, no refund - illegal in the EU', $tk$Hello,

I signed up for Pro on 2 October to test my site and cancelled on 20 October after I realised I did not need it. You took $25 when I upgraded and then another $13.91 on the day I cancelled. I have received nothing back. $38.91 for 18 days of a side project is ridiculous.

In France, and in the whole EU, I have a right of withdrawal on online services and a right to be reimbursed. I cancelled well within the month, so I should only pay for what I actually used. Please refund the full $38.91 to my card.

Camille Duret$tk$),
  ('TKT-7002', 'org_loom', 'sipho.dlamini@lumenloom.example', 'u_sipho', '2026-11-05 13:10:00+00', 'Charged $215 instead of about $35 - this is theft, reverse it today', $tk$Our invoice INV-2026-04130 from 3 November is $215.00. Every month before this we paid $35 or so. We have 42 monthly users. Forty-two. There is no way we generated hundreds of dollars of anything.

The usage page in the dashboard shows our egress at 236 GB and the limit is 250 GB, so we were UNDER the limit and should not have been charged anything extra. Either something is wrong with your billing or we are being attacked.

Please reverse the charge to my card today.

Sipho Dlamini
Lumen Loom Studio$tk$),
  ('TKT-7003', 'org_mara', 'amani.otieno@maramettrics.example', 'u_amani', '2026-11-06 07:42:00+00', '$92.31 for a $25 plan with Spend Cap ON - explain NOW', $tk$I am on the Pro plan. Pro is $25 a month. I have the Spend Cap switched ON, so I can never be billed more than my plan. Today I see invoice INV-2026-04131 for $92.31 and your system already took it from my card. That is nearly four times what I signed up for.

I have been a paying customer for over a year. I do not mind paying for what I use, but nobody told me about any of these extra charges and I do not see what I did to deserve this. If I do not get a correct invoice I will dispute the charge with my bank and move everything to another provider.

Amani Otieno
CTO, Mara Metrics Ltd$tk$),
  ('TKT-7004', 'org_saffron', 'hana.farouk@saffronapps.example', 'u_hana', '2026-11-06 11:11:00+00', 'Two questions about invoice INV-2026-04124', $tk$Hello,

Two questions on invoice INV-2026-04124.

1. My main project saffron-web runs on a Nano instance. I thought Nano was free, but I see a Compute Hours Nano line on the invoice with a charge.
2. My egress is getting close to the 250 GB quota. What are practical ways to reduce it? I have the Spend Cap on and I do not want my app to stop working.

Thanks,
Hana$tk$),
  ('TKT-7005', 'org_brandt_sw', 'lena.brandt@brandt-group.example', 'u_lena', '2026-11-07 09:15:00+00', 'INV-2026-04115 and INV-2026-04125: incorrect VAT - corrected invoices required by 12 November', $tk$Dear Sir or Madam,

We are a German company registered for VAT. We entered our VAT identification number in the billing settings of our Supabase organisation in August. Despite this, invoices INV-2026-04115 (20 September) and INV-2026-04125 (20 October) charged German VAT at 19% (USD 7.66 and USD 7.51). As a B2B customer with a valid VAT ID, the reverse-charge mechanism applies and no VAT should have been charged.

Our auditors require corrected invoices for our quarterly VAT filing, which closes on 12 November. Please reissue both invoices without VAT and refund the VAT charged to our payment method. Please also confirm in writing the legal entity that issued these invoices and its VAT registration number.

If we do not receive corrected invoices by 12 November we will withhold further payments, inform our tax advisor and consider our options with the Finanzamt.

Lena Brandt
Geschaeftsfuehrerin, Brandt Software GmbH$tk$),
  ('TKT-7006', NULL, 'priya.nair@kestrelworks.example', NULL, '2026-11-07 14:03:00+00', 'Pro vs Team, SOC 2 and annual billing', $tk$Hi,

We are evaluating Supabase for a healthcare analytics product. We expect three production projects, each roughly 120 GB of database data and about 2 million API requests a month.

Questions:
1. We need SOC 2 reports. Is that Pro or Team?
2. Can we pay annually by invoice or bank transfer instead of by card?
3. Roughly what would three Medium-compute projects cost per month?
4. Does the Spend Cap exist on Team?

Thanks,
Priya Nair
Kestrel Works$tk$),
  ('TKT-7007', 'org_harlow', 'imogen.harlow@harlowfinch.example', 'u_imogen', '2026-11-08 07:12:00+00', 'PRODUCTION DOWN 9 DAYS - you suspended our company without any warning', $tk$Our production database has been offline since 30 October. Nine days. Our customers cannot log in, we have lost two clients and we are looking at legal advice. Nobody at Supabase warned us. We received no email, no notice, nothing. We pay you every month on time and you shut us down in silence.

On Friday I topped up $200 of credit to settle whatever you think we owe. I was charged $240 for it. $240! You took $40 extra and only credited me $200, and the outstanding invoice STILL shows unpaid and the projects are still off.

I want the projects restored immediately, the extra $40 returned, and compensation for the damage. If this is not fixed today my solicitor will be in touch and I will dispute the $240 with my bank.

Imogen Harlow
Managing Director, Harlow & Finch Ltd$tk$),
  ('TKT-7008', 'org_lagom', 'oskar.lindqvist@lagomlabs.example', 'u_oskar', '2026-11-08 10:30:00+00', 'Changing the company card and downloading invoices', $tk$Hi,

Our company card is being replaced next month. How do I change the card used for our organisation? Can I remove the old card first? Also, where can I download PDF invoices for our accountant?

Thanks,
Oskar$tk$),
  ('TKT-7009', 'org_dune', 'felix.okafor@dunerobotics.example', 'u_felix', '2026-11-08 16:44:00+00', 'Cannot create a second free project - bug?', $tk$Hi,

I am on the Free plan and just tried to create a second project in my organisation, Dune Robotics. The dashboard says I have reached the free project limit, but I only have ONE active project, and I have never created any others. Is this a bug? We are prototyping and I do not want to upgrade just for this.

Felix$tk$),
  ('TKT-7010', NULL, 'devops@tidewater-cloud.example', NULL, '2026-11-09 07:20:00+00', 'Enable Spend Cap for AWS Marketplace organisation', $tk$Hello,

We subscribed to Supabase through AWS Marketplace last week. We would like to enable the Spend Cap for our organisation so we do not get surprise bills. Where do we switch it on? Our organisation is called Tidewater Platform.

Regards,
DevOps team, Tidewater Cloud$tk$),
  ('TKT-7011', 'org_meridian', 'rashid.almansoori@meridianfield.example', 'u_rashid', '2026-11-09 08:50:00+00', 'Paused project billed on invoice INV-2026-04133', $tk$Hi,

Invoice INV-2026-04133 (8 November) shows compute for the project mf-archive for 744 hours. We paused that project on 11 October and the project page confirms it has been paused since then. Your documentation says paused projects do not incur compute charges, and the usage page shows far fewer hours for that project in the 8 October to 8 November cycle.

Could you check the invoice? I am not asking for anything unreasonable. I would just like the invoice to match the usage.

Regards,
Rashid Al Mansoori$tk$),
  ('TKT-7012', NULL, 'accounts@bokforing-nord.example', NULL, '2026-11-09 09:05:00+00', 'Documents needed for Lagom Labs AB year-end', $tk$Hej,

I am the external accountant for Lagom Labs AB. Oskar asked me to collect documentation for the year-end. Please send me all 2026 invoices, the card details on file and the billing contact for the organisation. I cannot log in as I am not a member of the organisation.

Thanks,
Elin Strand
Bokforing Nord$tk$);

-- Follow-up conversations between customers and billing support for selected tickets.
INSERT INTO ticket_messages (ticket_id, seq, sent_at, sender_role, sender_email, body) VALUES
  ('TKT-7001', 1, '2026-11-05 10:02:00+00', 'support', 'billing-support@sim-support.example', $tk$Hello Camille,

We do not offer refunds. Any unused portion of your subscription fee has been added to your organization as credit which will remain on your account.

Regards,
Billing Support$tk$),
  ('TKT-7001', 2, '2026-11-06 21:40:00+00', 'customer', 'camille.duret@duretstudio.example', $tk$No. There is NO credit on my account, I checked the billing page and it says $0.00. So you are telling me something that is not true.

This is exactly what the DGCCRF and the European Consumer Centre exist for and I will file a complaint with both, and with my bank. I am a consumer, not a big company. I want a real explanation of the $13.91 (what did I use in 18 days?) and I want the refund.

Camille$tk$),
  ('TKT-7002', 1, '2026-11-05 15:30:00+00', 'support', 'billing-support@sim-support.example', $tk$Hi Sipho,

Thanks for reaching out. We reviewed your invoice. Usage above the included quota is charged at the published rate when the Spend Cap is turned off, so the invoice is correct.

Regards,
Billing Support$tk$),
  ('TKT-7002', 2, '2026-11-06 08:20:00+00', 'customer', 'sipho.dlamini@lumenloom.example', $tk$The Spend Cap is ON. I have never turned it off, I would remember. Your reply does not even say which usage I supposedly went over.

We are a small studio and $180 is a big deal to us this month. Who do I speak to who can actually look at this?$tk$),
  ('TKT-7002', 3, '2026-11-08 18:45:00+00', 'customer', 'sipho.dlamini@lumenloom.example', $tk$Third day without a real answer. If this is not reversed by Wednesday I will post my whole invoice on X and LinkedIn and tell every founder I know in Cape Town to avoid Supabase. We have also discussed a chargeback with our bank.

Please escalate this to a manager.$tk$),
  ('TKT-7003', 1, '2026-11-06 11:20:00+00', 'support', 'billing-support@sim-support.example', $tk$Hello Amani,

Thank you for contacting Supabase billing support. Your invoice includes compute usage and add-ons in addition to the Pro plan fee. Please refer to our billing documentation for details:
https://supabase.com/docs/guides/platform/billing-on-supabase

Best regards,
Billing Support$tk$),
  ('TKT-7003', 2, '2026-11-07 16:05:00+00', 'customer', 'amani.otieno@maramettrics.example', $tk$That is not an answer. A link to documentation is not an explanation. I asked WHY the Spend Cap did not protect me. I have read that page and I still do not see $92.

I want a line by line explanation from a human being, and a refund of everything above $25. I am giving you until Monday. After that I contact my bank and I will write about this experience publicly.

My developer Kofi says he turned something on for testing but that was supposed to be temporary and for pennies.$tk$),
  ('TKT-7005', 1, '2026-11-09 08:30:00+00', 'customer', 'lena.brandt@brandt-group.example', $tk$Reminder: no response since 7 November. The deadline of 12 November stands.

We have also noticed that the same VAT ID works without problems on our sister company's account, so this is clearly a fault on your side. Please escalate.$tk$),
  ('TKT-7007', 1, '2026-11-09 06:02:00+00', 'customer', 'imogen.harlow@harlowfinch.example', $tk$It is now over 22 hours since I wrote and I have had NOTHING. Not even an auto-reply saying you have seen it.

I have just logged in to the dashboard and our plan says Free now?!? Who authorised that? We are a paying Pro customer. Put it back. I want a phone number to call. If I do not hear from a human by noon I will be telling our clients and our investors exactly what Supabase did to us.$tk$),
  ('TKT-7011', 1, '2026-11-09 09:35:00+00', 'support', 'billing-support@sim-support.example', $tk$Hello Rashid,

Compute is billed hourly for each project in your organization. The invoice reflects the compute used during the billing period and is correct.

Regards,
Billing Support$tk$),
  ('TKT-7011', 2, '2026-11-09 10:12:00+00', 'customer', 'rashid.almansoori@meridianfield.example', $tk$Thanks for the quick reply, but that does not address my question. I am not asking how compute is billed in general. I am asking whether the hours on this invoice match the hours on your own usage page for this project.

Please have someone look at the actual hours rather than the general rule. If this is a known issue, tell me and I will wait. Otherwise please escalate. This is the second time my team has had to explain something to support this year.$tk$);
