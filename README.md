# 📦 Supply Chain Analytics Dashboard – Inventory & Fulfillment

### ✨ Overview
This project showcases a full-cycle **Supply Chain Analytics** solution using **Power BI**, focusing on:
- Inventory Management
- Fulfillment Analysis
- Sales & Profitability
- Market & Regional Insights

---

### 🗂️ Data Sources
The original raw data consisted of **3 main tables**:
- **Orders**
- **Inventory**
- **Fulfillments**

The Orders table was **denormalized**, containing customer, product, shipment, and order info.  
We applied **normalization**, splitting it into **8 tables**, with:

- `Fact_Order`
- `Fact_Shipment`
- Surrounding **dimension tables** (Customers, Products, Dates, etc.)

📌 Schema structure was initially built as a **Galaxy Schema**, then transformed into a clean **Star Schema** model in Power BI for optimal performance.

---

✅ A custom **ATL-like function** called `Clean` was developed, which automated:
- ❌ Removal of duplicate records
- 🕳️ Handling of null or missing values
- 🧾 Data type conversions (especially for `Date` columns)
- 🔄 Standardization of column formats across tables

This function was applied across multiple tables during the data preparation process, ensuring clean and consistent data for modeling.

---

### 📊 Power BI Modeling
- Combined `Fact_Order` and `Fact_Shipment` in a unified model
- Built strong relationships with dimensions
- Applied **DAX measures** for:
  - Total Sales
  - Total Profit
  - Profit Margin
  - AOV (Average Order Value)
  - Inventory Cost per Unit
  - Days in Fulfillment

---

### 📈 Dashboard Highlights
![Green Modern Minimalist Ecosystem Presentation (1)](https://github.com/user-attachments/assets/54fd80ec-0ee9-45ba-bf0c-775b1d436f28)
<img width="1327" height="882" alt="2" src="https://github.com/user-attachments/assets/bb7a26ed-6711-472b-8fe4-53248b600c7b" />
<img width="1336" height="888" alt="3" src="https://github.com/user-attachments/assets/45892ffb-3151-467a-905e-4550285710a5" />

#### 🧭 Inventory & Fulfillment KPIs
- 🟢 **71K Total Inventory Units**
- 🟡 Average Inventory Cost/Unit: **1.24**
- 🔴 Fulfillment Delays by Product
- 🏷️ Inventory by Warehouse, Category, and Region
<img width="1351" height="895" alt="4" src="https://github.com/user-attachments/assets/2f99ffc1-a517-4d19-afeb-03c6935ccfac" />

#### 🌍 Regional & Market Analysis
- 🗺️ 5 Markets – 23 Regions – 135 Countries
- 💸 Profit & Sales by Region / Country / Market
- 🛒 Customer distribution by region and market
<img width="1354" height="897" alt="1" src="https://github.com/user-attachments/assets/5dfad463-e9d9-4734-9bd3-1786e0a58cbe" />

#### 📦 Product Insights
- Top-selling products & departments (Outdoors, Fitness, Apparel...)
- Overstocked vs. Understocked categories
- Sales vs. Quantity vs. Profit per product

---

### 🧠 Business Value
- Improve stock distribution across warehouses
- Reduce overstock & understock issues
- Optimize fulfillment timing and logistics
- Support strategic market expansion decisions

---

### 🛠️ Tools Used
- 🧮 Microsoft Power BI (Data Modeling, Power Query, DAX)
- 📊 Star Schema Design
- 🧼 SQL for Data Normalization & Transformation
- 📦 Python for Data Cleaning

---


