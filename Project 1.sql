--C1
SELECT * FROM public.sales_dataset_rfm_prj
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN ordernumber TYPE integer USING (trim(ordernumber::integer)) 

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN quantityordered TYPE INTEGER USING (trim(quantityordered::integer));

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN priceeach TYPE DECIMAL(10,2) USING (trim(priceeach::decimal));

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN orderlinenumber TYPE INTEGER USING (trim(orderlinenumber::integer));

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN sales TYPE DECIMAL(15,2) USING (trim(sales::decimal));

--C2
SELECT * FROM public.sales_dataset_rfm_prj
WHERE ordernumber IS NULL
   OR quantityordered IS NULL
   OR priceeach IS NULL
   OR orderlinenumber IS NULL
   OR sales IS NULL
   OR orderdate IS NULL OR orderdate = '';

--C3
/* SPLIT_PART(contactfullname, '-', 1) sẽ lấy phần đầu tiên của chuỗi contactfullname (trước dấu gạch ngang) và gán cho contactlastname
SPLIT_PART(contactfullname, '-', 2) sẽ lấy phần thứ hai của chuỗi contactfullname (sau dấu gạch ngang) và gán cho contactfirstname */ 
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN CONTACTLASTNAME VARCHAR(50),
ADD COLUMN CONTACTFIRSTNAME VARCHAR(50);

UPDATE public.sales_dataset_rfm_prj
SET contactlastname = SPLIT_PART(contactfullname, '-', 1),
    contactfirstname = SPLIT_PART(contactfullname, '-', 2);

UPDATE SALES_DATASET_RFM_PRJ
SET CONTACTLASTNAME = CONCAT(UPPER(LEFT(CONTACTLASTNAME, 1)), LOWER(SUBSTRING(CONTACTLASTNAME, 2))),
    CONTACTFIRSTNAME = CONCAT(UPPER(LEFT(CONTACTFIRSTNAME, 1)), LOWER(SUBSTRING(CONTACTFIRSTNAME, 2)));

--C4  
ALTER TABLE public.sales_dataset_rfm_prj --Thêm cột tạm thời để lưu ngày đã chuyển đổi
ADD COLUMN orderdate_temp DATE;

UPDATE public.sales_dataset_rfm_prj  --Chuyển đổi giá trị của orderdate sang cột tạm thời với định dạng ngày hợp lệ
SET orderdate_temp = TO_DATE(orderdate, 'MM/DD/YYYY');

ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN QTR_ID INT,
ADD COLUMN MONTH_ID INT,
ADD COLUMN YEAR_ID INT;

UPDATE public.sales_dataset_rfm_prj
SET QTR_id = EXTRACT(QUARTER FROM orderdate_temp),
    MONTH_id = EXTRACT(MONTH FROM orderdate_temp),
    YEAR_id = EXTRACT(YEAR FROM orderdate_temp);

ALTER TABLE public.sales_dataset_rfm_prj --Xoá cột tạm thời nếu không cần thiết
DROP COLUMN orderdate_temp;

--C5.1
with twt_min_max_value as (
SELECT Q1-1.5*IQR AS min_value
	Q3+1.5*IQR AS max_value
FROM (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered) as Q1
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) as Q3
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) - percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered) as IQR
FROM ublic.sales_dataset_rfm_prj) AS a)

DELETE FROM public.sales_dataset_rfm_prj
WHERE quantityordered<(select min_value from twt_min_max_value)
OR quantityordered>(select max_value from twt_min_max_value)
--C5.2
WITH percentiles AS (
SELECT
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS Q1,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered) AS Q3
FROM public.sales_dataset_rfm_prj
),
iqr_values AS (
SELECT
Q1, Q3,(Q3 - Q1) AS IQR,
(Q1 - 1.5 * (Q3 - Q1)) AS lower_bound,
(Q3 + 1.5 * (Q3 - Q1)) AS upper_bound
FROM percentiles
),
avg_quantity AS (
    SELECT AVG(quantityordered) AS avg_quantity
    FROM public.sales_dataset_rfm_prj
)
UPDATE public.sales_dataset_rfm_prj
SET quantityordered = avg_quantity.avg_quantity
FROM iqr_values, avg_quantity
WHERE quantityordered < lower_bound OR quantityordered > upper_bound;
