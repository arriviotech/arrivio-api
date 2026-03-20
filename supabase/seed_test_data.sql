-- ============================================================
-- SEED DATA — 50 Properties with Units, Pricing, Amenities, Photos
-- Run this in Supabase SQL Editor (staging only)
-- ============================================================

-- ── PROPERTIES ─────────────────────────────────────────────

INSERT INTO properties (id, name, slug, description, address_line1, city, postal_code, district, latitude, longitude, property_type, available_for, house_rules, manager_name, manager_phone, manager_email, status) VALUES

-- BERLIN (15 properties)
('a0000001-0000-0000-0000-000000000001', 'Arrivio Mitte Residence', 'arrivio-mitte-residence', 'Modern furnished apartments in the heart of Berlin Mitte. Walking distance to Alexanderplatz, Museum Island, and major tech hubs. Perfect for professionals relocating to Berlin.', 'Torstraße 45', 'Berlin', '10119', 'Mitte', 52.5290, 13.4010, 'apartment_building', ARRAY['professional','azubi','student'], 'Quiet hours 22:00–07:00. No smoking indoors. Recycling mandatory.', 'Sarah Müller', '+49 30 12345601', 'sarah@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000002', 'Kreuzberg Loft Studios', 'kreuzberg-loft-studios', 'Industrial-chic loft studios in vibrant Kreuzberg. Surrounded by cafes, galleries, and the Landwehr Canal. High ceilings, exposed brick, and modern furnishings.', 'Oranienstraße 120', 'Berlin', '10969', 'Kreuzberg', 52.4990, 13.4180, 'apartment_building', ARRAY['professional','azubi'], 'Quiet hours 22:00–07:00. Bike storage available in courtyard.', 'Thomas Weber', '+49 30 12345602', 'thomas@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000003', 'Prenzlauer Berg Suites', 'prenzlauer-berg-suites', 'Elegant serviced apartments in one of Berlin''s most sought-after neighborhoods. Tree-lined streets, boutique shopping, and excellent transport links.', 'Kastanienallee 28', 'Berlin', '10435', 'Prenzlauer Berg', 52.5380, 13.4130, 'serviced_apartments', ARRAY['professional'], 'Weekly cleaning included. No pets. Guest registration required.', 'Anna Schmidt', '+49 30 12345603', 'anna@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000004', 'Neukölln Student House', 'neukolln-student-house', 'Affordable student housing in multicultural Neukölln. Shared kitchens, study rooms, and a rooftop terrace. Close to multiple universities and the Ringbahn.', 'Karl-Marx-Straße 85', 'Berlin', '12043', 'Neukölln', 52.4810, 13.4320, 'student_residence', ARRAY['student','azubi'], 'Shared spaces must be cleaned after use. Quiet study hours 20:00–08:00.', 'Lisa Braun', '+49 30 12345604', 'lisa@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000005', 'Charlottenburg Classic', 'charlottenburg-classic', 'Renovated Altbau apartments near Kurfürstendamm. Grand rooms, stucco ceilings, and modern kitchens. Premium location for professionals.', 'Kantstraße 55', 'Berlin', '10627', 'Charlottenburg', 52.5060, 13.3110, 'apartment_building', ARRAY['professional'], 'No parties. Building quiet after 22:00. Courtyard access for residents only.', 'Michael Lange', '+49 30 12345605', 'michael@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000006', 'Friedrichshain Shared Living', 'friedrichshain-shared-living', 'Community-focused shared houses near the East Side Gallery. Spacious common areas, shared gardens, and regular community events.', 'Warschauer Straße 70', 'Berlin', '10243', 'Friedrichshain', 52.5070, 13.4490, 'shared_house', ARRAY['professional','azubi','student'], 'Community dinner every Wednesday. Shared cleaning schedule. No smoking.', 'Julia Hoffmann', '+49 30 12345606', 'julia@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000007', 'Wedding Studio Apartments', 'wedding-studio-apartments', 'Newly built studio apartments in up-and-coming Wedding. Affordable, well-connected, and close to the TU Berlin campus.', 'Müllerstraße 130', 'Berlin', '13353', 'Wedding', 52.5510, 13.3490, 'apartment_building', ARRAY['student','azubi','professional'], 'Recycling is mandatory. Laundry room hours 07:00–22:00.', 'Klaus Fischer', '+49 30 12345607', 'klaus@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000008', 'Schöneberg Garden Residences', 'schoneberg-garden-residences', 'Quiet garden apartments in leafy Schöneberg. Perfect for families and professionals who appreciate green spaces and a relaxed atmosphere.', 'Hauptstraße 22', 'Berlin', '10827', 'Schöneberg', 52.4890, 13.3530, 'apartment_building', ARRAY['professional'], 'Garden access for all residents. BBQ area by reservation. Pets allowed with deposit.', 'Eva Richter', '+49 30 12345608', 'eva@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000009', 'Spandau Riverside', 'spandau-riverside', 'Modern apartments along the Havel river in Spandau. Peaceful setting with excellent S-Bahn connections to central Berlin.', 'Breite Straße 18', 'Berlin', '13597', 'Spandau', 52.5350, 13.2010, 'apartment_building', ARRAY['professional','azubi'], 'Riverside terrace shared. Boat storage available. Quiet hours apply.', 'Peter Koch', '+49 30 12345609', 'peter@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000010', 'Tempelhof Serviced Living', 'tempelhof-serviced-living', 'Premium serviced apartments near Tempelhof Field. All-inclusive living with weekly cleaning, high-speed internet, and concierge service.', 'Tempelhofer Damm 100', 'Berlin', '12099', 'Tempelhof', 52.4680, 13.3870, 'serviced_apartments', ARRAY['professional'], 'Concierge available 08:00–20:00. All utilities included. Monthly deep clean.', 'Maria Becker', '+49 30 12345610', 'maria@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000011', 'Adlershof Tech Campus', 'adlershof-tech-campus', 'Purpose-built accommodation for tech professionals and researchers at the Adlershof Science City. Co-working spaces and gym included.', 'Albert-Einstein-Straße 4', 'Berlin', '12489', 'Adlershof', 52.4310, 13.5310, 'apartment_building', ARRAY['professional','student'], 'Co-working space open 24/7. Gym hours 06:00–23:00.', 'Dirk Schäfer', '+49 30 12345611', 'dirk@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000012', 'Moabit Urban Living', 'moabit-urban-living', 'Stylish apartments in central Moabit, minutes from the Hauptbahnhof. Ideal for newcomers who need quick access to all of Berlin.', 'Turmstraße 60', 'Berlin', '10551', 'Moabit', 52.5270, 13.3440, 'apartment_building', ARRAY['professional','azubi','student'], 'Package reception at front desk. Bike parking in basement.', 'Stefanie Vogel', '+49 30 12345612', 'stefanie@arrivio.de', 'coming_soon'),

('a0000001-0000-0000-0000-000000000013', 'Lichtenberg Student Village', 'lichtenberg-student-village', 'Affordable student village with 200+ rooms. Common rooms, study lounges, and a cinema room. Direct tram to Alexanderplatz.', 'Frankfurter Allee 250', 'Berlin', '10365', 'Lichtenberg', 52.5150, 13.4890, 'student_residence', ARRAY['student','azubi'], 'Student ID required. Guests must sign in. Quiet hours strictly enforced.', 'Markus Klein', '+49 30 12345613', 'markus@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000014', 'Steglitz Family Homes', 'steglitz-family-homes', 'Spacious two-bedroom apartments in family-friendly Steglitz. Near schools, parks, and the Botanical Garden.', 'Schloßstraße 80', 'Berlin', '12163', 'Steglitz', 52.4570, 13.3210, 'apartment_building', ARRAY['professional'], 'Family-friendly building. Playground in courtyard. Pets welcome.', 'Katharina Wolf', '+49 30 12345614', 'katharina@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000015', 'Pankow Green Residences', 'pankow-green-residences', 'Eco-friendly apartments in green Pankow. Solar-powered, energy-efficient, with a community garden and composting facilities.', 'Breite Straße 25', 'Berlin', '13187', 'Pankow', 52.5680, 13.4060, 'apartment_building', ARRAY['professional','student'], 'Composting mandatory. Community garden plots available. Car-free courtyard.', 'Henrik Bauer', '+49 30 12345615', 'henrik@arrivio.de', 'coming_soon'),

-- MUNICH (10 properties)
('a0000001-0000-0000-0000-000000000016', 'Schwabing Premium Apartments', 'schwabing-premium-apartments', 'Upscale apartments in Munich''s most desirable neighborhood. Near the English Garden, Ludwig-Maximilians-Universität, and Leopoldstraße.', 'Leopoldstraße 40', 'Munich', '80802', 'Schwabing', 48.1590, 11.5820, 'apartment_building', ARRAY['professional'], 'Premium building. Doorman available. Underground parking included.', 'Franz Huber', '+49 89 12345616', 'franz@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000017', 'Maxvorstadt Student Hub', 'maxvorstadt-student-hub', 'Central student accommodation between TU München and LMU. Walking distance to Pinakothek museums and the main university campus.', 'Theresienstraße 60', 'Munich', '80333', 'Maxvorstadt', 48.1510, 11.5690, 'student_residence', ARRAY['student','azubi'], 'Study rooms open 24/7. Free printing. Bike repair station.', 'Claudia Maier', '+49 89 12345617', 'claudia@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000018', 'Haidhausen Altbau Living', 'haidhausen-altbau-living', 'Charming renovated Altbau apartments in the French Quarter of Munich. Historic building with modern interiors, near the Isar river.', 'Wörthstraße 15', 'Munich', '81667', 'Haidhausen', 48.1310, 11.5960, 'apartment_building', ARRAY['professional','azubi'], 'Historic building — no drilling after 20:00. Cellar storage included.', 'Wolfgang Gruber', '+49 89 12345618', 'wolfgang@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000019', 'Sendling Shared House', 'sendling-shared-house', 'Community-oriented shared living in Sendling. Large shared kitchen, garden, and weekly movie nights. Great for social newcomers.', 'Aberlestraße 30', 'Munich', '81371', 'Sendling', 48.1190, 11.5510, 'shared_house', ARRAY['professional','azubi','student'], 'Shared meals on Sundays. Cleaning rota in shared areas. No overnight guests without notice.', 'Barbara Winkler', '+49 89 12345619', 'barbara@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000020', 'Bogenhausen Executive Suites', 'bogenhausen-executive-suites', 'Executive-level serviced apartments in prestigious Bogenhausen. Full concierge, daily housekeeping, and premium furnishings.', 'Prinzregentenstraße 85', 'Munich', '81675', 'Bogenhausen', 48.1440, 11.6050, 'serviced_apartments', ARRAY['professional'], 'Full service. Daily cleaning. Minibar restocked weekly. Airport shuttle available.', 'Heinrich Steiner', '+49 89 12345620', 'heinrich@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000021', 'Giesing Budget Studios', 'giesing-budget-studios', 'Affordable well-furnished studios in Giesing. Good transport links, close to local markets, and a growing food scene.', 'Tegernseer Landstraße 50', 'Munich', '81541', 'Giesing', 48.1110, 11.5830, 'apartment_building', ARRAY['student','azubi'], 'Laundry tokens from reception. Building quiet after 22:00.', 'Renate Schwarz', '+49 89 12345621', 'renate@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000022', 'Moosach Tech Living', 'moosach-tech-living', 'Modern apartments near BMW HQ and the tech corridor. Ideal for automotive professionals and engineers.', 'Bunzlauer Straße 10', 'Munich', '80992', 'Moosach', 48.1790, 11.5170, 'apartment_building', ARRAY['professional'], 'Secure parking. EV charging stations. High-speed fiber internet.', 'Ulrich Berger', '+49 89 12345622', 'ulrich@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000023', 'Lehel Boutique Residences', 'lehel-boutique-residences', 'Intimate boutique residence near the Eisbach wave and English Garden. Only 12 apartments, each uniquely designed.', 'Liebigstraße 8', 'Munich', '80538', 'Lehel', 48.1430, 11.5890, 'serviced_apartments', ARRAY['professional'], 'Boutique property. Personal welcome. Weekly flowers. Concierge.', 'Ingrid Hartmann', '+49 89 12345623', 'ingrid@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000024', 'Laim Transit Hub', 'laim-transit-hub', 'Conveniently located apartments at the Laim S-Bahn junction. Reach any part of Munich within 20 minutes. Modern, practical, affordable.', 'Landsberger Straße 300', 'Munich', '80687', 'Laim', 48.1410, 11.5100, 'apartment_building', ARRAY['professional','azubi','student'], 'Shared laundry. Package lockers. 24/7 key access.', 'Gerhard Roth', '+49 89 12345624', 'gerhard@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000025', 'Garching University Residence', 'garching-university-residence', 'Steps from TU München Garching campus. Built for researchers and students. Lab-quality internet and study spaces.', 'Boltzmannstraße 5', 'Munich', '85748', 'Garching', 48.2650, 11.6710, 'student_residence', ARRAY['student','professional'], 'University shuttle included. 24/7 study rooms. Bike rental.', 'Sabine Keller', '+49 89 12345625', 'sabine@arrivio.de', 'active'),

-- FRANKFURT (8 properties)
('a0000001-0000-0000-0000-000000000026', 'Westend Finance Quarter', 'westend-finance-quarter', 'Premium apartments in Frankfurt''s financial district. Walking distance to the Bankenviertel, ECB, and Palmengarten.', 'Bockenheimer Landstraße 50', 'Frankfurt', '60325', 'Westend', 50.1180, 8.6630, 'apartment_building', ARRAY['professional'], 'Professional building. 24/7 security. Underground parking.', 'Jürgen Wagner', '+49 69 12345626', 'jurgen@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000027', 'Sachsenhausen Riverside', 'sachsenhausen-riverside', 'Apartments along the Main river in historic Sachsenhausen. Near Museumsufer and the famous Apfelwein district.', 'Schweizer Straße 35', 'Frankfurt', '60594', 'Sachsenhausen', 50.1030, 8.6820, 'apartment_building', ARRAY['professional','azubi'], 'River-view terrace shared. Recycling stations on each floor.', 'Monika Engel', '+49 69 12345627', 'monika@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000028', 'Bockenheim Student Quarter', 'bockenheim-student-quarter', 'Former Goethe University area, now a vibrant student neighborhood. Affordable rooms with great community spirit.', 'Leipziger Straße 20', 'Frankfurt', '60487', 'Bockenheim', 50.1220, 8.6440, 'student_residence', ARRAY['student','azubi'], 'Common room events weekly. Study groups encouraged. Free laundry.', 'Petra Zimmermann', '+49 69 12345628', 'petra@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000029', 'Nordend Creative Studios', 'nordend-creative-studios', 'Artist-friendly studios in creative Nordend. Open floor plans, abundant natural light, and a communal art space.', 'Berger Straße 90', 'Frankfurt', '60316', 'Nordend', 50.1230, 8.6910, 'apartment_building', ARRAY['professional','student'], 'Art studio in basement. Gallery wall in lobby rotates monthly.', 'Ralf Krause', '+49 69 12345629', 'ralf@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000030', 'Gallus New Build', 'gallus-new-build', 'Brand new development in the transforming Gallus district. Energy-efficient, smart-home enabled, near the Hauptbahnhof.', 'Mainzer Landstraße 200', 'Frankfurt', '60326', 'Gallus', 50.1050, 8.6480, 'apartment_building', ARRAY['professional','azubi','student'], 'Smart home app provided. Package delivery room. Rooftop terrace.', 'Silke Meyer', '+49 69 12345630', 'silke@arrivio.de', 'coming_soon'),

('a0000001-0000-0000-0000-000000000031', 'Bornheim Village Homes', 'bornheim-village-homes', 'Cozy apartments in village-like Bornheim. Local bakeries, the weekly market, and a strong sense of community.', 'Berger Straße 250', 'Frankfurt', '60385', 'Bornheim', 50.1280, 8.7030, 'shared_house', ARRAY['professional','azubi','student'], 'Community garden. Weekly market trips organized. Shared kitchen equipped.', 'Christoph Lehmann', '+49 69 12345631', 'christoph@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000032', 'Ostend Harbour Living', 'ostend-harbour-living', 'Modern waterfront apartments at the new Osthafen development. Views of the Frankfurt skyline and direct river access.', 'Hanauer Landstraße 150', 'Frankfurt', '60314', 'Ostend', 50.1110, 8.7120, 'apartment_building', ARRAY['professional'], 'Harbour-front terrace. Kayak storage. Premium finishes throughout.', 'Andrea Frank', '+49 69 12345632', 'andrea@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000033', 'Rödelheim Green Quarter', 'rodelheim-green-quarter', 'Family-friendly apartments surrounded by parks in quiet Rödelheim. Excellent schools nearby and quick S-Bahn access.', 'Radilostraße 12', 'Frankfurt', '60489', 'Rödelheim', 50.1280, 8.6120, 'apartment_building', ARRAY['professional'], 'Children''s play area. Quiet family building. Storage rooms available.', 'Birgit Schulz', '+49 69 12345633', 'birgit@arrivio.de', 'active'),

-- HAMBURG (7 properties)
('a0000001-0000-0000-0000-000000000034', 'St. Pauli Creative Hub', 'st-pauli-creative-hub', 'Vibrant living in Hamburg''s most iconic neighborhood. Near the Reeperbahn, harbour, and a thriving startup scene.', 'Feldstraße 40', 'Hamburg', '20357', 'St. Pauli', 53.5570, 9.9650, 'shared_house', ARRAY['professional','azubi','student'], 'Creative community. Noise-tolerant building. Rooftop events monthly.', 'Lars Petersen', '+49 40 12345634', 'lars@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000035', 'Eimsbüttel Garden Apartments', 'eimsbuttel-garden-apartments', 'Charming apartments in green Eimsbüttel. Near Sternschanze, the university, and beautiful parks.', 'Osterstraße 55', 'Hamburg', '20259', 'Eimsbüttel', 53.5740, 9.9570, 'apartment_building', ARRAY['professional','student'], 'Garden access. Cellar storage. Friendly building community.', 'Katrin Jansen', '+49 40 12345635', 'katrin@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000036', 'HafenCity Waterfront', 'hafencity-waterfront', 'Luxury waterfront apartments in Hamburg''s newest district. Elbphilharmonie views, premium amenities, and harbour living.', 'Am Sandtorkai 30', 'Hamburg', '20457', 'HafenCity', 53.5410, 9.9900, 'serviced_apartments', ARRAY['professional'], 'Concierge. Harbour views. Spa access. Weekly housekeeping.', 'Sven Brandt', '+49 40 12345636', 'sven@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000037', 'Altona Student Living', 'altona-student-living', 'Budget-friendly student rooms near the Altona train station. Quick connections to all Hamburg universities.', 'Große Bergstraße 20', 'Hamburg', '22767', 'Altona', 53.5520, 9.9360, 'student_residence', ARRAY['student','azubi'], 'Study lounges. Free coffee. Bike workshop. Monthly social events.', 'Anja Krüger', '+49 40 12345637', 'anja@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000038', 'Winterhude Premium Living', 'winterhude-premium-living', 'Upscale apartments on the Alster canal in peaceful Winterhude. Jogging paths, sailing clubs, and excellent restaurants.', 'Mühlenkamp 30', 'Hamburg', '22303', 'Winterhude', 53.5840, 10.0010, 'apartment_building', ARRAY['professional'], 'Alster canal access. Private garden. Underground parking.', 'Ole Hansen', '+49 40 12345638', 'ole@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000039', 'Barmbek Shared Homes', 'barmbek-shared-homes', 'Friendly shared houses in Barmbek. Great for newcomers wanting to build connections. Shared cooking, movie nights, and language exchange.', 'Fuhlsbüttler Straße 100', 'Hamburg', '22305', 'Barmbek', 53.5870, 10.0380, 'shared_house', ARRAY['professional','azubi','student'], 'Language exchange Tuesdays. Shared cooking Fridays. Cleaning rota.', 'Nina Wolff', '+49 40 12345639', 'nina@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000040', 'Wandsbek Family Residences', 'wandsbek-family-residences', 'Spacious family apartments in suburban Wandsbek. Near international schools, shopping centers, and green spaces.', 'Wandsbeker Marktstraße 60', 'Hamburg', '22041', 'Wandsbek', 53.5720, 10.0690, 'apartment_building', ARRAY['professional'], 'Family building. Playground. Storage rooms. Quiet after 21:00.', 'Heike Lorenz', '+49 40 12345640', 'heike@arrivio.de', 'active'),

-- DÜSSELDORF (5 properties)
('a0000001-0000-0000-0000-000000000041', 'Altstadt Executive Residences', 'altstadt-executive-residences', 'Executive apartments in Düsseldorf''s historic Old Town. Steps from the Rhine promenade, Königsallee, and major corporate offices.', 'Bolkerstraße 15', 'Düsseldorf', '40213', 'Altstadt', 51.2270, 6.7740, 'serviced_apartments', ARRAY['professional'], 'Full concierge. Dry cleaning. Rhine terrace. Premium furnishings.', 'Rainer Scholz', '+49 211 1234541', 'rainer@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000042', 'Bilk University Quarter', 'bilk-university-quarter', 'Student and young professional housing near Heinrich Heine University. Affordable, modern, and well-connected.', 'Bilker Allee 80', 'Düsseldorf', '40219', 'Bilk', 51.2110, 6.7680, 'student_residence', ARRAY['student','azubi'], 'Study rooms. Free printing. Campus shuttle. Weekly game nights.', 'Tanja Schrader', '+49 211 1234542', 'tanja@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000043', 'Medienhafen Lofts', 'medienhafen-lofts', 'Stunning loft apartments in the architecturally iconic MedienHafen. Gehry buildings as neighbors. Hub for media and creative industries.', 'Speditionstraße 20', 'Düsseldorf', '40221', 'Medienhafen', 51.2170, 6.7530, 'apartment_building', ARRAY['professional'], 'Harbour views. Gym access. Co-working space. Rooftop lounge.', 'Marco Baumann', '+49 211 1234543', 'marco@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000044', 'Flingern Creative Living', 'flingern-creative-living', 'Trendy neighborhood with street art, indie shops, and craft breweries. Shared living for creative professionals.', 'Ackerstraße 40', 'Düsseldorf', '40233', 'Flingern', 51.2270, 6.8020, 'shared_house', ARRAY['professional','azubi','student'], 'Art supplies in common room. Monthly gallery visits. Creative community.', 'Sonja Hermann', '+49 211 1234544', 'sonja@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000045', 'Oberkassel Riverside', 'oberkassel-riverside', 'Elegant apartments across the Rhine in upscale Oberkassel. Panoramic skyline views and a village-like atmosphere.', 'Luegallee 25', 'Düsseldorf', '40545', 'Oberkassel', 51.2330, 6.7520, 'apartment_building', ARRAY['professional'], 'Rhine views. Private balconies. Underground parking. Premium area.', 'Volker Arndt', '+49 211 1234545', 'volker@arrivio.de', 'active'),

-- STUTTGART (3 properties)
('a0000001-0000-0000-0000-000000000046', 'Stuttgart West Panorama', 'stuttgart-west-panorama', 'Hillside apartments with panoramic views of the Stuttgart valley. Near Porsche and Bosch headquarters. Excellent for automotive professionals.', 'Rotebühlstraße 100', 'Stuttgart', '70178', 'Stuttgart-West', 48.7700, 9.1630, 'apartment_building', ARRAY['professional'], 'Valley views. Underground parking. EV charging. Smart home.', 'Hannes Koenig', '+49 711 1234546', 'hannes@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000047', 'Vaihingen Campus Residence', 'vaihingen-campus-residence', 'Right on the University of Stuttgart campus in Vaihingen. Research labs, libraries, and the Mensa within walking distance.', 'Pfaffenwaldring 45', 'Stuttgart', '70569', 'Vaihingen', 48.7420, 9.1030, 'student_residence', ARRAY['student','azubi'], 'Campus access. Lab-grade internet. Study rooms 24/7. Free gym.', 'Gabi Werner', '+49 711 1234547', 'gabi@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000048', 'Bad Cannstatt Mineral Springs', 'bad-cannstatt-mineral-springs', 'Apartments near Europe''s second-largest mineral springs. Historic spa town atmosphere with modern living standards.', 'Marktstraße 30', 'Stuttgart', '70372', 'Bad Cannstatt', 48.8010, 9.2100, 'apartment_building', ARRAY['professional','azubi'], 'Spa access nearby. Mineral water on tap. Neckar river walks.', 'Florian Seidel', '+49 711 1234548', 'florian@arrivio.de', 'active'),

-- COLOGNE (2 properties)
('a0000001-0000-0000-0000-000000000049', 'Ehrenfeld Hipster Quarter', 'ehrenfeld-hipster-quarter', 'The beating heart of Cologne''s alternative scene. Street art, vinyl shops, and the best döner in NRW. Shared living at its finest.', 'Venloer Straße 200', 'Cologne', '50823', 'Ehrenfeld', 50.9510, 6.9180, 'shared_house', ARRAY['professional','azubi','student'], 'Rooftop cinema in summer. Vinyl listening room. Community kitchen.', 'Yasemin Özdemir', '+49 221 1234549', 'yasemin@arrivio.de', 'active'),

('a0000001-0000-0000-0000-000000000050', 'Deutz Rheinblick', 'deutz-rheinblick', 'Modern apartments in Deutz with direct views of the Cologne Cathedral across the Rhine. KölnMesse and LANXESS arena at your doorstep.', 'Deutz-Mülheimer Straße 40', 'Cologne', '50679', 'Deutz', 50.9370, 6.9740, 'apartment_building', ARRAY['professional'], 'Cathedral views. Trade fair access. Rhine promenade. Modern building.', 'Tobias Schmitz', '+49 221 1234550', 'tobias@arrivio.de', 'active');


-- ── UNITS (3-5 per property, ~180 total) ───────────────────

-- Helper: Generate units for each property
-- Using a pattern: each property gets 3-5 units of varying types and tiers

DO $$
DECLARE
  prop RECORD;
  unit_count INTEGER;
  i INTEGER;
  unit_types TEXT[] := ARRAY['studio', 'one_bedroom', 'two_bedroom', 'shared_room'];
  tiers TEXT[] := ARRAY['standard', 'premium', 'executive'];
  u_type TEXT;
  u_tier TEXT;
  u_floor INTEGER;
  u_size NUMERIC;
BEGIN
  FOR prop IN SELECT id, property_type FROM properties WHERE deleted_at IS NULL
  LOOP
    -- Determine how many units
    unit_count := 3 + floor(random() * 3)::int; -- 3 to 5

    FOR i IN 1..unit_count
    LOOP
      -- Pick unit type based on property type
      IF prop.property_type = 'student_residence' THEN
        u_type := (ARRAY['shared_room', 'studio', 'studio'])[1 + floor(random() * 3)::int];
      ELSIF prop.property_type = 'shared_house' THEN
        u_type := (ARRAY['shared_room', 'shared_room', 'studio'])[1 + floor(random() * 3)::int];
      ELSIF prop.property_type = 'serviced_apartments' THEN
        u_type := (ARRAY['studio', 'one_bedroom', 'one_bedroom', 'two_bedroom'])[1 + floor(random() * 4)::int];
      ELSE
        u_type := unit_types[1 + floor(random() * 4)::int];
      END IF;

      -- Pick tier
      IF prop.property_type = 'serviced_apartments' THEN
        u_tier := (ARRAY['premium', 'executive'])[1 + floor(random() * 2)::int];
      ELSIF prop.property_type = 'student_residence' THEN
        u_tier := 'standard';
      ELSE
        u_tier := tiers[1 + floor(random() * 3)::int];
      END IF;

      -- Floor and size
      u_floor := floor(random() * 6)::int;
      u_size := CASE u_type
        WHEN 'shared_room' THEN 14 + floor(random() * 8)::int
        WHEN 'studio' THEN 22 + floor(random() * 15)::int
        WHEN 'one_bedroom' THEN 35 + floor(random() * 20)::int
        WHEN 'two_bedroom' THEN 55 + floor(random() * 25)::int
      END;

      INSERT INTO units (property_id, unit_number, floor, unit_type, max_occupants, size_sqm, status, tier, is_furnished)
      VALUES (
        prop.id,
        CONCAT(u_floor, LPAD(i::text, 2, '0')),
        u_floor,
        u_type,
        CASE u_type WHEN 'shared_room' THEN 2 WHEN 'studio' THEN 1 WHEN 'one_bedroom' THEN 2 WHEN 'two_bedroom' THEN 4 END,
        u_size,
        (ARRAY['available', 'available', 'available', 'occupied'])[1 + floor(random() * 4)::int],
        u_tier,
        TRUE
      );
    END LOOP;
  END LOOP;
END $$;


-- ── UNIT PRICING RULES ─────────────────────────────────────

-- Add pricing for every unit, per tenant type
DO $$
DECLARE
  u RECORD;
  base_rent INTEGER;
  deposit_multiplier INTEGER;
BEGIN
  FOR u IN SELECT id, unit_type, tier FROM units WHERE deleted_at IS NULL
  LOOP
    -- Base rent in cents based on type + tier
    base_rent := CASE u.unit_type
      WHEN 'shared_room' THEN 45000  -- €450
      WHEN 'studio' THEN 75000       -- €750
      WHEN 'one_bedroom' THEN 110000 -- €1,100
      WHEN 'two_bedroom' THEN 160000 -- €1,600
    END;

    -- Tier multiplier
    IF u.tier = 'premium' THEN base_rent := (base_rent * 1.3)::int; END IF;
    IF u.tier = 'executive' THEN base_rent := (base_rent * 1.6)::int; END IF;

    deposit_multiplier := 2;

    -- Professional pricing
    INSERT INTO unit_pricing_rules (unit_id, tenant_type, monthly_rent_cents, security_deposit_cents, holding_deposit_cents, min_stay_months, max_stay_months)
    VALUES (u.id, 'professional', base_rent, base_rent * deposit_multiplier, 15000, 3, 24)
    ON CONFLICT DO NOTHING;

    -- Student pricing (15% cheaper)
    INSERT INTO unit_pricing_rules (unit_id, tenant_type, monthly_rent_cents, security_deposit_cents, holding_deposit_cents, min_stay_months, max_stay_months)
    VALUES (u.id, 'student', (base_rent * 0.85)::int, (base_rent * 0.85 * deposit_multiplier)::int, 15000, 6, 12)
    ON CONFLICT DO NOTHING;

    -- Azubi pricing (10% cheaper)
    INSERT INTO unit_pricing_rules (unit_id, tenant_type, monthly_rent_cents, security_deposit_cents, holding_deposit_cents, min_stay_months, max_stay_months)
    VALUES (u.id, 'azubi', (base_rent * 0.90)::int, (base_rent * 0.90 * deposit_multiplier)::int, 15000, 3, 36)
    ON CONFLICT DO NOTHING;

    -- B2B pricing (5% premium)
    INSERT INTO unit_pricing_rules (unit_id, tenant_type, monthly_rent_cents, security_deposit_cents, holding_deposit_cents, min_stay_months, max_stay_months)
    VALUES (u.id, 'b2b', (base_rent * 1.05)::int, (base_rent * 1.05 * deposit_multiplier)::int, 0, 1, 36)
    ON CONFLICT DO NOTHING;
  END LOOP;
END $$;


-- ── UNIT AMENITIES ──────────────────────────────────────────

-- Give each unit 5-10 random amenities
DO $$
DECLARE
  u RECORD;
  amenity RECORD;
  amenity_count INTEGER;
  counter INTEGER;
BEGIN
  FOR u IN SELECT id, tier FROM units WHERE deleted_at IS NULL
  LOOP
    counter := 0;
    amenity_count := CASE u.tier
      WHEN 'standard' THEN 5 + floor(random() * 3)::int
      WHEN 'premium' THEN 7 + floor(random() * 3)::int
      WHEN 'executive' THEN 9 + floor(random() * 3)::int
    END;

    FOR amenity IN SELECT id FROM amenity_catalogue WHERE is_active = TRUE ORDER BY random() LIMIT amenity_count
    LOOP
      INSERT INTO unit_amenities (unit_id, amenity_id)
      VALUES (u.id, amenity.id)
      ON CONFLICT DO NOTHING;
    END LOOP;
  END LOOP;
END $$;


-- ── PROPERTY PHOTOS (placeholder URLs) ──────────────────────

-- Each property gets 4-6 photos using Unsplash placeholder images
DO $$
DECLARE
  prop RECORD;
  photo_count INTEGER;
  i INTEGER;
  photo_categories TEXT[] := ARRAY[
    'apartment-interior', 'modern-kitchen', 'bedroom-design',
    'living-room', 'bathroom-modern', 'building-exterior',
    'city-view', 'balcony', 'workspace'
  ];
BEGIN
  FOR prop IN SELECT id, name, city FROM properties WHERE deleted_at IS NULL
  LOOP
    photo_count := 4 + floor(random() * 3)::int; -- 4 to 6

    FOR i IN 1..photo_count
    LOOP
      INSERT INTO property_photos (property_id, storage_path, alt_text, caption, is_primary, display_order)
      VALUES (
        prop.id,
        CONCAT('property-photos/', prop.id, '/photo-', i, '.jpg'),
        CONCAT(prop.name, ' - Photo ', i),
        CASE i
          WHEN 1 THEN 'Building exterior'
          WHEN 2 THEN 'Living area'
          WHEN 3 THEN 'Modern kitchen'
          WHEN 4 THEN 'Bedroom'
          WHEN 5 THEN 'Bathroom'
          WHEN 6 THEN 'Common area'
        END,
        i = 1, -- First photo is primary
        i
      );
    END LOOP;
  END LOOP;
END $$;


-- ── VERIFY ──────────────────────────────────────────────────
SELECT 'Properties: ' || count(*) FROM properties;
SELECT 'Units: ' || count(*) FROM units;
SELECT 'Pricing rules: ' || count(*) FROM unit_pricing_rules;
SELECT 'Unit amenities: ' || count(*) FROM unit_amenities;
SELECT 'Property photos: ' || count(*) FROM property_photos;
