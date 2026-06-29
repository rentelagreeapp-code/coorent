-- Consolidated SQL script to insert sample listings for Tractors, JCB, Cars, and Drones.
-- Includes Latitude and Longitude coordinates and uses transparent background PNGs.

INSERT INTO public."RentalServices" (
    "Id", 
    "CategoryName", 
    "Title", 
    "Description", 
    "PriceDetails", 
    "ImageUrl", 
    "CreatedDate",
    "Latitude",
    "Longitude"
) VALUES 
(
    'a7b3d1f8-8f5c-4bca-8e01-9a7f348e02d1',
    'Tractors',
    'John Deere 5050D Tractor',
    'Reliable 50 HP tractor suitable for plowing, tilling, and heavy haulage. Equipped with power steering.',
    '₹2500 / Day',
    'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png',
    CURRENT_TIMESTAMP,
    28.6139,
    77.2090
),
(
    'a9f8e7d6-c5b4-4a3b-9a8b-7c6d5e4f3a2b',
    'JCB',
    'JCB 3DX Backhoe Loader',
    'Heavy-duty backhoe loader ideal for farm excavation, land clearing, and general earthmoving tasks.',
    '₹8000 / Day',
    'https://pngimg.com/uploads/excavator/excavator_PNG16.png',
    CURRENT_TIMESTAMP,
    28.6250,
    77.2150
),
(
    'b2a1c0d9-e8f7-6a5b-4c3d-2e1f0a9b8c7d',
    'Cars',
    'Mahindra Bolero Camper (4x4)',
    'Sturdy 4x4 pickup utility car, ideal for transporting farm produce and navigating rough rural terrains.',
    '₹3500 / Day',
    'https://pngimg.com/uploads/suv/suv_PNG101252.png',
    CURRENT_TIMESTAMP,
    28.6050,
    77.2000
),
(
    'c3d2e1f0-a9b8-8c7d-6e5f-4a3b2c1d0e9f',
    'Drones',
    'DJI Agras T40 Spraying Drone',
    'Advanced agricultural drone featuring coaxial twin rotors and a 40 kg spraying payload for crop care.',
    '₹9500 / Day',
    'https://pngimg.com/uploads/drone/drone_PNG9.png',
    CURRENT_TIMESTAMP,
    28.6180,
    77.2250
);
