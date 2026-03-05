# Lab 11 - Event & Reminder App (Flutter + SQLite + Provider)

แอปพลิเคชันจัดการกิจกรรมและการแจ้งเตือนแบบออฟไลน์ พัฒนาด้วย Flutter โดยใช้ SQLite ในการจัดการฐานข้อมูลและ Provider สำหรับจัดการ State ของแอปพลิเคชัน 

## 🚀 1. วิธีรันโปรเจกต์

1. Clone โปรเจกต์นี้ลงเครื่อง
   git clone https://github.com/Phanawut/flutter_SQLite_provider_lab11.git

2. เข้าไปที่โฟลเดอร์โปรเจกต์
   cd flutter_sqlite_provider_lab11

3. ติดตั้ง Dependencies ทั้งหมด (Provider, Sqflite, Intl, Path)
   flutter pub get

4. รันแอปพลิเคชัน (แนะนำให้รันบน Android Emulator หรือเชื่อมต่อมือถือ Android)
   flutter run

   (หมายเหตุ: หากต้องการรันบน iOS หรือ macOS ต้องทำการ cd ios หรือ cd macos แล้วรัน pod install ก่อน)

---

## 🗄️ 2. โครงสร้างตารางฐานข้อมูล (Database Structure)

ออกแบบฐานข้อมูล SQLite โดยมี 2 ตารางหลักที่เชื่อมความสัมพันธ์กัน (One-to-Many) ดังนี้:

### ตาราง categories (ประเภทกิจกรรม)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| id | INTEGER | Primary Key (AUTOINCREMENT) |
| name | TEXT | ชื่อประเภทกิจกรรม (เช่น งาน, ส่วนตัว) |
| color_hex | TEXT | โค้ดสีสำหรับแสดงผล (เช่น #2196F3) |
| icon_key | TEXT | ชื่อไอคอนสำหรับแสดงผล |

### ตาราง events (กิจกรรม)
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| id | INTEGER | Primary Key (AUTOINCREMENT) |
| title | TEXT | ชื่อกิจกรรม |
| description | TEXT | รายละเอียดเพิ่มเติม |
| category_id | INTEGER | Foreign Key เชื่อมไปยัง categories.id |
| event_date | TEXT | วันที่จัดกิจกรรม (YYYY-MM-DD) |
| start_time | TEXT | เวลาเริ่มต้น (HH:mm) |
| end_time | TEXT | เวลาสิ้นสุด (HH:mm) |
| status | TEXT | สถานะ (pending, in_progress, completed, cancelled) |
| priority | INTEGER | ระดับความสำคัญ (1=ต่ำ, 2=ปกติ, 3=สูง) |
| remind_enabled| INTEGER | เปิด/ปิด แจ้งเตือน (0=ปิด, 1=เปิด) |
| remind_minutes| INTEGER | เตือนก่อนล่วงหน้า (นาที) |
| updated_at | TEXT | เวลาที่แก้ไขล่าสุด (สำหรับจัดเรียง) |

---

## ✨ 3. รายการฟีเจอร์ที่ทำได้ (Features)

การจัดการประเภทกิจกรรม (Category Management): 
- [x] เพิ่ม/ลบ ประเภทกิจกรรม พร้อมกำหนดสีและไอคอนได้
- [x] ตรวจสอบก่อนลบ: ไม่สามารถลบประเภทที่มีกิจกรรมใช้งานอยู่ได้

การจัดการกิจกรรม (Event Management): 
- [x] เพิ่ม/แก้ไข/ลบ กิจกรรมได้ครบถ้วน
- [x] Validation: ตรวจสอบความถูกต้องว่า "เวลาสิ้นสุด" ต้องมากกว่า "เวลาเริ่ม" เสมอ
- [x]ระบุระดับความสำคัญ (ต่ำ/ปกติ/สูง) และตั้งค่าการแจ้งเตือน (เตือนก่อน X นาที) เก็บลง Database 

การแสดงผล ค้นหา กรอง และจัดเรียง (UI/UX & Filter): 
- [x] แสดงรายการเป็นรูปแบบ Card พร้อม Badge สีตามประเภทกิจกรรมอย่างชัดเจน
- [x] Search: ค้นหากิจกรรมจากชื่อ (Title)
- [x] Filter: กรองข้อมูลตามช่วงเวลา (ทั้งหมด/วันนี้/สัปดาห์นี้/เดือนนี้) 
- [x] Filter: กรองข้อมูลตาม "สถานะ" และ "หมวดหมู่"
- [x] Sort: จัดเรียงรายการตาม "เวลาเริ่มใกล้สุด" หรือ "อัปเดตล่าสุด" 

---

## 📸 4. Screenshots

<img width="794" height="628" alt="Screenshot 2569-02-26 at 02 58 46" src="https://github.com/user-attachments/assets/14d99173-119a-457f-888b-02cd20717384" />
<img width="794" height="757" alt="Screenshot 2569-02-26 at 02 59 47" src="https://github.com/user-attachments/assets/6142165e-1fe8-4d2f-88f4-cf3d84592e5e" />
<img width="791" height="758" alt="Screenshot 2569-02-26 at 03 00 06" src="https://github.com/user-attachments/assets/dd7aec1b-af4e-4c02-92b1-dfe33ce4e99f" />
<img width="789" height="757" alt="Screenshot 2569-02-26 at 03 00 15" src="https://github.com/user-attachments/assets/d5516baf-db37-4f46-9d41-9fa954db798a" />
<img width="793" height="763" alt="Screenshot 2569-02-26 at 03 00 35" src="https://github.com/user-attachments/assets/f00d9962-5884-406a-ba16-837282933c19" />
<img width="800" height="440" alt="Screenshot 2569-02-26 at 03 00 48" src="https://github.com/user-attachments/assets/82c0bf34-f0a3-41c7-9d96-9a6c86eeb2a9" />
