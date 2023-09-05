

--DATA CLEANING 


----1. Finding the total number of customers?
select count(customerid)no_of_customers from customers;

---here we are finding about number of customers we have


----2. Checking for duplicate rows?
select customerid,count(customerid)cnt
from customers
group by customerid
having count(customerid)>1;  --- no duplicate value as such



---Checking for null values
select 'tenure' as column_name ,count(*)no_of_null_values from customers 
where tenure is null
group by Tenure
union
select 'WarehouseToHome' as column_name ,count(*)no_of_null_values from customers
where WarehouseToHome is null
group by WarehouseToHome
union
select 'hourspendonapp' as column_name ,count(*)no_of_null_values from customers
where HourSpendOnApp is null
group by HourSpendOnApp
union
select 'OrderAmountHikeFromlastYear' as column_name ,count(*)no_of_null_values from customers
where OrderAmountHikeFromlastYear is null
group by OrderAmountHikeFromlastYear 
union
select 'OrderCount' as column_name ,count(*)no_of_null_values from customers
where OrderCount is null
group by OrderCount
union
select 'DaySinceLastOrder' as column_name ,count(*)no_of_null_values from customers 
where DaySinceLastOrder is null
group by DaySinceLastOrder
union
select 'CouponUsed' as column_name ,count(*)no_of_null_values from customers 
where CouponUsed is null
group by CouponUsed

--we are shown null values of each and we would try to correct it


---missing value treatment
update customers 
set tenure = (select avg(tenure) from customers)
where tenure is null

update customers
set warehousetohome = (select avg(warehousetohome) from customers)
where warehousetohome is null 

update  customers 
set hourspendonapp  = (select avg(hourspendonapp) from customers)
where hourspendonapp is null 

update customers
set OrderAmountHikeFromlastYear   = (select avg(OrderAmountHikeFromlastYear ) from customers)
where OrderAmountHikeFromlastYear  is null


update customers
set  OrderCount  = (select avg(OrderCount ) from customers)
where OrderCount  is null


update customers 
set  daysincelastorder  = (select avg(daysincelastorder) from customers)
where daysincelastorder  is null

update customers 
set couponused = 0
where couponused is null




----Creating a new column from an already existing “churn” column??
alter table customers
add  customer_status varchar(20)

---use alter to add a column 
update customers 
set customer_status = 
case 
when churn = 1 then 'churned'
when churn = 0 then 'stayed'
end 

----created and put values in customer_status




--- Creating a new column from an already existing “complain” column?
alter table customers 
add complainedstatus varchar(10) --- created column complainedstatus

update customers 
set complainedstatus = 
case
when complain = 1 then 'Yes'
when complain = 0 then 'NO'
end ;--- put values in the column complained_status

----preparing data for further analysis 
select distinct preferredlogindevice from customers
update customers
set preferredlogindevice='phone'
where preferredlogindevice = 'mobile phone' ---making values same for whole dataset

select distinct PreferredPaymentMode from customers
update customers
set PreferredPaymentMode='E-Wallet'
where PreferredPaymentMode = 'E wallet' 

update customers
set PreferredPaymentMode='Cash on delivery'
where PreferredPaymentMode = 'COD'

update customers
set PreferredPaymentMode='Credit Card'
where PreferredPaymentMode = 'CC'


select distinct PreferedOrderCat from customers
update customers 
set PreferedOrderCat = 'mobile phone '
where PreferedOrderCat = 'mobile'

select distinct MaritalStatus from customers

select distinct warehousetohome from customers 


update customers 
set warehousetohome='27'
where warehousetohome = '127'


update customers 
set warehousetohome='26'
where warehousetohome = '126'

---1. What is the overall customer churn rate?
select 
total_cust,churned_cust,
cast((churned_cust*1.0/total_cust*1.0)*100 as decimal(12,2))rate 
from 
(select count(customerid)total_cust from customers)total_customers,
(select sum(churn)churned_cust from customers)total_churned_cust;


---here we can see we have 5630 customers and out of which 948 had churned,16.84% of total.







---2. How does the churn rate vary based on the preferred login device?
select device,
total_cust,churn_cust,cast((churn_cust/total_cust)*100 as decimal(12,2))as rate 
from 
(select Preferredlogindevice as device ,count(customerid)total_cust,sum(churn)churn_cust from customers
group by PreferredLoginDevice)x


--- here we can we have customers those using phone and computer ,have churn_rate of 15.62 and 19.83 respectively








---3. What is the distribution of customers across different city tiers?
select CityTier,
total_cust,churned_cust,cast((churned_cust/total_cust)*100 as decimal(12,2))as rate from
(select citytier ,count(customerid)total_cust,sum(churn)churned_cust from customers
group by CityTier)x

--- we have citytier and their churn rate . citytier 1,2 and 3 and their churn rate is 14.51,19.83,21.37 respectively .
----Among all 3 tier cities have highest number of customer churned.

---4. Is there any correlation between the warehouse-to-home distance and customer churn?
alter table customers 
add distance_status varchar(20)

update customers 
set distance_status = 
case 
when warehousetohome<10 then 'very close distance' 
when WarehouseToHome>=10 and WarehouseToHome<=20then 'close distance '
when WarehouseToHome>20 and WarehouseToHome<=30 then 'far distance'
when WarehouseToHome> 30 then 'too far'
end ;
---here we made another column of distance_status which is showing about distance e.g. far,close ,too far etc 

select 
distance_status,
total_cust,churned_cust,
cast((churned_cust/total_cust)*100 as decimal(12,2))as rate 
from
(select distance_status,count(customerid)total_cust,sum(churn)churned_cust from customers
group by distance_status)x
order by 2,3;



---5. Which is the most preferred payment mode among churned customers?
select preferredpaymentmode,
total_cust,churned_cust,
cast((churned_cust/total_cust)*100 as decimal(12,2))as rate from (select preferredpaymentmode,count(customerid)total_cust,sum(churn)churned_cust from customers
group by PreferredPaymentMode)v

---we have different payment mode such as e-wallet ,COD,,debit card ,UPI etc and we have COD CUSTOMERS THOSE ARE churning with a highest rate 

---6. What is the typical tenure for churned customers?
alter table customers
add tenure_category varchar(50)

update customers
set tenure_category =
case 
when tenure <= 6 then '6 months'
when tenure > 6 and tenure<=12 then '1 year'
when tenure >12 and tenure <=24 then '2 year'
when tenure > 24 then 'morethan 2 years'
end ;
---here we made classification on tenure e.g. 6 months,1 year and 2 year
select tenure_category,
total_cust,churned_cust,
cast((churned_cust/total_cust)*100 as decimal(12,2))rate from 
(select tenure_category,count(customerid)total_cust,sum(churn)churned_cust from customers 
group by tenure_category)x



---7. Is there any difference in churn rate between male and female customers?
select gender,total_cust,churned_cust,
cast((churned_cust/total_cust)*100 as decimal(12,2))rate
from
(select gender,count(customerid)total_cust,sum(churn)churned_cust from customers 
group by gender)x;


---- Male seems to have highest churn rate as compared with female

---8. How does the average time spent on the app differ for churned and non-churned customers?
select customer_status,cast(avg(hourspendonapp)as int )average_time from customers 
group by customer_status;

---9. Does the number of registered devices impact the likelihood of churn?
select registered_device,
total_cust
,churned_cust, 
cast((churned_cust/total_cust)*100 as decimal(12,2))rate 
from(select NumberOfDeviceRegistered as registered_device,count(customerid)total_cust,sum(churn)churned_cust 
from customers 
group by NumberOfDeviceRegistered)x
order by 1;




--10. Which order category is most preferred among churned customers?
select order_category,
total_cust
,churned_cust, 
cast((churned_cust/total_cust)*100 as decimal(12,2))rate 
from(select PreferedOrderCat as order_category,count(customerid)total_cust,sum(churn)churned_cust from customers 
group by Preferedordercat)x


--- category wise mobile phones seems to have highest churn_rate


--11. Is there any relationship between customer satisfaction scores and churn?
select score,total_cust,churned_cust,
cast((churned_cust/total_cust)*100 as decimal(12,2))rate 
from(select SatisfactionScore as score,count(customerid)total_cust,sum(churn)churned_cust from customers 
group by SatisfactionScore)x
order by 1

---those who gave highest scores the churned ones .



--12. Does the marital status of customers influence churn behavior?
select MaritalStatus,total_cust,churned_cust, 
cast((churned_cust/total_cust)*100 as decimal(12,2))rate
from(select MaritalStatus,count(customerid)total_cust,sum(churn)churned_cust
from customers 
group by MaritalStatus)x


--- as per data singles are one who churned the most.
--13. How many addresses do churned customers have on average?
select avg(NumberOfAddress) from customers
where customer_status='Churn'


--14. Do customer complaints influence churned behavior?

select complainedstatus,
total_cust,churned_cust,
cast((churned_cust/total_cust)*100 as decimal(12,2))rate from(select complainedstatus,count(customerid)total_cust,sum(churn)churned_cust
from customers
group by complainedstatus)x

--15. How does the use of coupons differ between churned and non-churned customers?
select customer_status,sum(CouponUsed)coupon from customers 
group by customer_status

--- churned customers did not use coupons as such.

--16. What is the average number of days since the last order for churned customers?
select cast(avg(DaySinceLastOrder) as int)avg_day from customers
where customer_status='churned'


--- 3 days are average 

--17. Is there any correlation between cashback amount and churn rate?
alter table customers 
add cashbacks varchar(50) 

update customers 
set cashbacks =
case 
when CashbackAmount<= 100 then 'low_cashback_amt'
when CashbackAmount>100 and CashbackAmount<=200 then 'good_amt_cashback'
when CashbackAmount>200 and CashbackAmount<=300 then 'high_amt_cashback'
when CashbackAmount>300 then 'very_high'
end 

select cashbacks,total_cust,churned_cust,cast((churned_cust/total_cust)*100 as decimal(15,2))rate from
(select cashbacks,count(customerid)total_cust,sum(churn)churned_cust from customers 
group by cashbacks)x
--we have some customers moving in despite of having good amount of cashback