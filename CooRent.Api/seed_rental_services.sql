-- Script to insert Master Data into the RentalServices table
-- Generates seed data for Tractor, Harvester, Equipment, Transport, Seeds, and Labor categories.

INSERT INTO "RentalServices" ("Id", "CategoryName", "Title", "Description", "PriceDetails", "ImageUrl", "CreatedDate")
VALUES
  -- Category: Tractor Rental
  (gen_random_uuid(), 'Tractor Rental', 'John Deere 5050D Pro', '50 HP utility tractor, highly reliable and fuel-efficient, perfect for tillage, sowing, and heavy-duty farm tasks.', '₹900 / hr', 'https://images.unsplash.com/photo-1592928302636-c83cf1e1c887?w=300', NOW()),
  (gen_random_uuid(), 'Tractor Rental', 'Mahindra Novo 605', '57 HP high-torque tractor with advanced hydraulics, suitable for large-scale agricultural cultivation.', '₹1,000 / hr', 'https://images.unsplash.com/photo-1594142426462-a57bbd222c11?w=300', NOW()),
  
  -- Category: Harvester Rental
  (gen_random_uuid(), 'Harvester Rental', 'Kubota Harvester DC-70G', 'Premium combine harvester optimized for rice and wheat harvesting, reduces grain loss and features high speed operations.', '₹1,800 / hr', 'https://images.unsplash.com/photo-1574382352842-1e967a505bfa?w=300', NOW()),
  (gen_random_uuid(), 'Harvester Rental', 'John Deere W70', 'Multi-crop combine harvester equipped with large grain tank capacity and heavy-duty straw walkers.', '₹2,200 / hr', 'https://images.unsplash.com/photo-1530906358829-e84b276e1f97?w=300', NOW()),

  -- Category: Equipment Rental
  (gen_random_uuid(), 'Equipment Rental', 'Heavy Duty Rotavator', 'Multi-speed rotary tiller used for soil preparation, clod breaking, and mixing crop residues.', '₹350 / hr', 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=300', NOW()),
  (gen_random_uuid(), 'Equipment Rental', 'Automatic Seed Drill', 'Precision mechanical seed drill providing uniform sowing depth and optimal spacing between rows.', '₹400 / hr', 'https://images.unsplash.com/photo-1463123081488-729f60cff35a?w=300', NOW()),

  -- Category: Transport
  (gen_random_uuid(), 'Transport', 'Tata Ace Gold Mini Truck', 'Compact cargo loading vehicle ideal for transporting farm inputs, fertilizers, and smaller crop yields to local markets.', '₹1,200 / trip', 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=300', NOW()),
  (gen_random_uuid(), 'Transport', 'Heavy Duty Farm Trailer', 'Large loading capacity double-axle trailer designed to transport grains and crop yields in bulk.', '₹700 / day', 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=300', NOW()),

  -- Category: Seeds
  (gen_random_uuid(), 'Seeds', 'Premium Hybrid Wheat Seeds (50kg)', 'High yielding, disease resistant premium hybrid wheat grain seed bags prepared for seasonal sowing.', '₹2,400 / bag', 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=300', NOW()),
  (gen_random_uuid(), 'Seeds', 'Organic Corn Kernels (25kg)', 'Certified organic non-GMO sweet corn seeds optimized for rapid germination and drought tolerance.', '₹1,500 / bag', 'https://images.unsplash.com/photo-1551754625-7fc5ad945131?w=300', NOW()),

  -- Category: Labor
  (gen_random_uuid(), 'Labor', 'Skilled Harvesting Crew (3 members)', 'Professional farm laborers trained in manual harvesting, crop handling, loading, and field clearing.', '₹1,500 / day', 'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?w=300', NOW())
ON CONFLICT DO NOTHING;
