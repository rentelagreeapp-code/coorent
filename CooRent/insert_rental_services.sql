-- SQL Script to insert 10 sample agricultural equipment/services into public."RentalServices"
-- Uses transparent PNG images (no background) to integrate seamlessly with the app UI.

INSERT INTO public."RentalServices" (
    "Id", 
    "CategoryName", 
    "Title", 
    "Description", 
    "PriceDetails", 
    "ImageUrl", 
    "CreatedDate"
) VALUES 
(
    'a7b3d1f8-8f5c-4bca-8e01-9a7f348e02d1',
    'Tractors',
    'John Deere 5050D Tractor',
    'Highly reliable 50 HP tractor suitable for heavy agricultural applications like plowing, tilling, and haulage. Equipped with power steering.',
    '₹2500 / Day',
    'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png',
    CURRENT_TIMESTAMP
),
(
    'c2e45f91-2a8b-4c3e-9081-3fd9a2b5e672',
    'Harvesters',
    'Mahindra Combine Harvester',
    'High-performance combine harvester designed for rapid and efficient harvesting of wheat, paddy, and corn with minimal grain loss.',
    '₹6000 / Day',
    'https://pngimg.com/uploads/combine_harvester/combine_harvester_PNG37.png',
    CURRENT_TIMESTAMP
),
(
    'e9b0d23c-7b6a-484d-91b2-ef8c5a4d9134',
    'Tillage Equipment',
    'Heavy Duty Soil Rotavator',
    'Premium quality rotavator with L-type blades, perfect for seedbed preparation, soil mixing, and pulverizing weeds in dry and wet lands.',
    '₹1200 / Day',
    'https://pngimg.com/uploads/plow/plow_PNG5.png',
    CURRENT_TIMESTAMP
),
(
    'f3c4e5d6-8a7b-4d9e-a0c1-b2d3e4f5a6b7',
    'Plant Protection',
    'DJI Agras T30 Spraying Drone',
    'Digital spraying drone with a 30L spray tank. Ideal for precision crop spraying, liquid pesticide/fertilizer application.',
    '₹8000 / Day',
    'https://pngimg.com/uploads/drone/drone_PNG9.png',
    CURRENT_TIMESTAMP
),
(
    'b7c8d9e0-f1a2-4b3c-8d4e-5f6a7b8c9d0e',
    'Irrigation',
    'Kirloskar 5HP Water Pump',
    'High-capacity centrifugal pump powered by a reliable engine. Built for continuous operation in remote fields with zero grid access.',
    '₹800 / Day',
    'https://pngimg.com/uploads/water_pump/water_pump_PNG41.png',
    CURRENT_TIMESTAMP
),
(
    'a1b2c3d4-e5f6-4789-9012-a3b4c5d6e7f8',
    'Landscaping & Clearing',
    'Honda 4-Stroke Brush Cutter',
    'Ergonomic, low-vibration brush cutter suitable for harvesting grass, clearing weeds, and trimming light foliage around fields.',
    '₹500 / Day',
    'https://pngimg.com/uploads/lawn_mower/lawn_mower_PNG103.png',
    CURRENT_TIMESTAMP
),
(
    '8f7e6d5c-4b3a-2f1e-0d9c-8b7a6f5e4d3c',
    'Tillage Equipment',
    '9-Tyne Spring Loaded Cultivator',
    'Designed for heavy-duty weeding and loosening of soil. Suitable for rocky and tough soil types, preparing it for the next crop cycle.',
    '₹1000 / Day',
    'https://pngimg.com/uploads/plow/plow_PNG3.png',
    CURRENT_TIMESTAMP
),
(
    'd1c2b3a4-e5f6-4789-8091-a2b3c4d5e6f7',
    'Sowing & Planting',
    '9-Tyne Automatic Seed Drill',
    'Sows seeds and applies fertilizer simultaneously. Adjusts spacing and depth dynamically. Perfect for wheat, maize, and pulses.',
    '₹1500 / Day',
    'https://pngimg.com/uploads/plow/plow_PNG5.png',
    CURRENT_TIMESTAMP
),
(
    '9e8d7c6b-5a4f-3e2d-1c0b-9a8f7e6d5c4b',
    'Harvest Processing',
    'Paddy & Straw Square Baler',
    'Pulls behind tractor to compress loose straw or hay into neat, compact, transportable square bales. Saves storage space.',
    '₹2000 / Day',
    'https://pngimg.com/uploads/tractor/tractor_PNG16281.png',
    CURRENT_TIMESTAMP
),
(
    '7e6d5c4b-3a2f-1e0d-9c8b-7a6f5e4d3c2b',
    'Post-Harvest',
    'Multi-Crop Thresher (10 HP)',
    'Efficiently threshes wheat, mustard, millet, and soybean crops. Driven by electric motor or tractor PTO, separating grains cleanly.',
    '₹1800 / Day',
    'https://pngimg.com/uploads/combine_harvester/combine_harvester_PNG37.png',
    CURRENT_TIMESTAMP
),
(
    'a9f8e7d6-c5b4-4a3b-9a8b-7c6d5e4f3a2b',
    'JCB',
    'JCB 3DX EcoXcellence',
    'Heavy duty backhoe loader ideal for farm excavation, land clearing, pond digging, and general agricultural construction tasks.',
    '₹8000 / Day',
    'https://pngimg.com/uploads/excavator/excavator_PNG16.png',
    CURRENT_TIMESTAMP
),
(
    'b2a1c0d9-e8f7-6a5b-4c3d-2e1f0a9b8c7d',
    'Cars',
    'Mahindra Bolero Camper (4x4)',
    'Sturdy 4x4 pickup utility car, ideal for transporting heavy farm produce, navigating rough rural terrains, and passenger commuting.',
    '₹3500 / Day',
    'https://pngimg.com/uploads/suv/suv_PNG101252.png',
    CURRENT_TIMESTAMP
),
(
    'c3d2e1f0-a9b8-8c7d-6e5f-4a3b2c1d0e9f',
    'Drones',
    'DJI Agras T40 Spraying Drone',
    'Revolutionary agricultural drone featuring coaxial twin rotors, a spreading payload of 50 kg, and a spraying payload of 40 kg for high-efficiency crop care.',
    '₹9500 / Day',
    'https://pngimg.com/uploads/drone/drone_PNG9.png',
    CURRENT_TIMESTAMP
);
