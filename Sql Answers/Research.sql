-- Q1 How does the revenue generated from document registration vary across districts in Telangana? List down the top 5 districts that showed the highest revenue growth between FY 2019 and 2022.

SELECT
		district AS districts,
		ROUND(SUM(documents_registered_rev)/1000000000 ,2)AS 'Revenue (in Billion)'
FROM
		fact_stamps fs
JOIN
		dim_districts dd ON dd.dist_code = fs.dist_code
GROUP BY
		district
ORDER BY
		[Revenue (in Billion)] DESC OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY

-- Q2 How does the revenue generated from document registration compare to the revenue generated from e-stamp challans across districts? List down the top 5 districts where e-stamps revenue contributes significantly more to the revenue than the documents in FY 2022?

SELECT
		district AS District,
		ROUND(CAST(SUM(documents_registered_rev)AS FLOAT)/1000000000 ,2) AS 'Documents Revenue (in Billion)',
		ROUND(CAST(SUM(estamps_challans_rev)AS FLOAT)/1000000000, 2) AS 'E-stamps Revenue (in Billion)'
FROM
		fact_stamps fs
JOIN
		dim_districts ds ON ds.dist_code = fs.dist_code
JOIN
		dim_date dd ON dd.month = fs.month
WHERE 
		dd.fiscal_year = 2022
GROUP BY
		district
HAVING 
		SUM(estamps_challans_rev) > SUM(documents_registered_rev)
ORDER BY
		[E-stamps Revenue (in Billion)] DESC OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY

--  Q3 Is there any alteration of e-Stamp challan count and document registration count pattern since the implementation of e-Stamp challan? If so, what suggestions would you propose to the government?
SELECT 
		'2019' AS Year, 
		SUM(CASE WHEN YEAR(month) = 2019 THEN documents_registered_cnt END) AS 'Documents Registered',
		SUM(CASE WHEN YEAR(month) = 2019 THEN estamps_challans_cnt END) AS 'E-Stamp Challan',
		SUM(CASE WHEN YEAR(month) = 2019 THEN documents_registered_cnt END) - SUM(CASE WHEN YEAR(month) = 2019 THEN estamps_challans_cnt END) AS differences
FROM 
		fact_stamps
UNION ALL

SELECT 
		'2020' AS Year, 
		SUM(CASE WHEN YEAR(month) = 2020 THEN documents_registered_cnt END) AS 'Documents Registered',
		SUM(CASE WHEN YEAR(month) = 2020 THEN estamps_challans_cnt END) AS 'E-Stamp Challan',
		SUM(CASE WHEN YEAR(month) = 2020 THEN documents_registered_cnt END) - SUM(CASE WHEN YEAR(month) = 2020 THEN estamps_challans_cnt END) AS differences

FROM 
		fact_stamps

UNION ALL

SELECT 
		'2021' AS Year, 
		SUM(CASE WHEN YEAR(month) = 2021 THEN documents_registered_cnt END) AS 'Documents Registered',
		SUM(CASE WHEN YEAR(month) = 2021 THEN estamps_challans_cnt END) AS 'E-Stamp Challan',
		SUM(CASE WHEN YEAR(month) = 2021 THEN documents_registered_cnt END) - SUM(CASE WHEN YEAR(month) = 2021 THEN estamps_challans_cnt END) AS differences

FROM fact_stamps

UNION ALL

SELECT 
		'2022' AS Year, 
		SUM(CASE WHEN YEAR(month) = 2022 THEN documents_registered_cnt END) AS 'Documents Registered',
		SUM(CASE WHEN YEAR(month) = 2022 THEN estamps_challans_cnt END) AS 'E-Stamp Challan',
		SUM(CASE WHEN YEAR(month) = 2022 THEN documents_registered_cnt END) - SUM(CASE WHEN YEAR(month) = 2022 THEN estamps_challans_cnt END) AS differences

FROM 
		fact_stamps;

-- Q4 Categorize districts into three segments based on their stamp registration revenue generation during the fiscal year 2021 to 2022.

SELECT
		district AS District,
		CASE WHEN NTILE(3) OVER (ORDER BY SUM(documents_registered_rev) DESC)=1 THEN SUM(documents_registered_rev)/10000000 END AS 'High Revenue',
		CASE WHEN NTILE(3) OVER (ORDER BY SUM(documents_registered_rev) DESC)=2 THEN SUM(documents_registered_rev)/10000000 END AS 'Medium Revenue',
		CASE WHEN NTILE(3) OVER (ORDER BY SUM(documents_registered_rev) DESC)=3 THEN SUM(documents_registered_rev)/10000000 END AS 'Low Revenue'
FROM
		fact_stamps fs
JOIN
		dim_date dd ON dd.month = fs.month
JOIN
		dim_districts ds ON ds.dist_code = fs.dist_code
WHERE
		fiscal_year = 2022
GROUP BY
		district


-- Transportation
-- Q5. Investigate whether there is any correlation between vehicle sales and specific months or seasons in different districts. Are there any months or seasons that consistently show higher sale rates, and if yes, what could be the driving factors?
SELECT
		MONTH(ft.month) AS Monthy_sales,
		YEAR(ft.month) AS Yearly_sales,
		SUM(vehicleClass_MotorCycle)+ SUM(vehicleClass_MotorCar) + SUM(vehicleClass_AutoRickshaw) + SUM(vehicleClass_Agriculture) + SUM(vehicleClass_others) AS total_vehicles
		
FROM
		fact_transport ft
GROUP BY
		MONTH(ft.month),
		YEAR(ft.month)
ORDER BY
		total_vehicles DESC

-- Q6 How does the distribution of vehicles vary by vehicle class (MotorCycle, MotorCar, AutoRickshaw, Agriculture) across different districts? Are there any districts with a predominant preference for a specific vehicle class? Consider FY 2022 for analysis.

SELECT
		district,
		SUM(vehicleClass_MotorCycle)+ SUM(vehicleClass_MotorCar) + SUM(vehicleClass_AutoRickshaw) + SUM(vehicleClass_Agriculture) + SUM(vehicleClass_others) AS total_vehicles,
		SUM(vehicleClass_MotorCycle) AS 'Motor Cycle',
		SUM(vehicleClass_MotorCar) AS 'Motor Car',
		SUM(vehicleClass_AutoRickshaw) AS 'Auto Rickshaw',
		SUM(vehicleClass_Agriculture) AS 'Agriculture',
		SUM(vehicleClass_others) AS 'Other Vehicles',
		ROUND(CAST(SUM(vehicleClass_MotorCycle)*100.0 AS FLOAT) /(SUM(vehicleClass_MotorCycle)+ SUM(vehicleClass_MotorCar) + SUM(vehicleClass_AutoRickshaw) + SUM(vehicleClass_Agriculture) + SUM(vehicleClass_others)),2) AS 'MotorCycle Percentage',
		ROUND(CAST(SUM(vehicleClass_MotorCar)*100.0 AS FLOAT) /(SUM(vehicleClass_MotorCycle)+ SUM(vehicleClass_MotorCar) + SUM(vehicleClass_AutoRickshaw) + SUM(vehicleClass_Agriculture) + SUM(vehicleClass_others)),2) AS 'MotorCar Percentage',
		ROUND(CAST(SUM(vehicleClass_AutoRickshaw)*100.0 AS FLOAT) /(SUM(vehicleClass_MotorCycle)+ SUM(vehicleClass_MotorCar) + SUM(vehicleClass_AutoRickshaw) + SUM(vehicleClass_Agriculture) + SUM(vehicleClass_others)),2) AS 'AutoRickshaw Percentage',
		ROUND(CAST(SUM(vehicleClass_Agriculture)*100.0 AS FLOAT) /(SUM(vehicleClass_MotorCycle)+ SUM(vehicleClass_MotorCar) + SUM(vehicleClass_AutoRickshaw) + SUM(vehicleClass_Agriculture) + SUM(vehicleClass_others)),2) AS 'Agriculture Percentage',
		ROUND(CAST(SUM(vehicleClass_others)*100.0 AS FLOAT) /(SUM(vehicleClass_MotorCycle)+ SUM(vehicleClass_MotorCar) + SUM(vehicleClass_AutoRickshaw) + SUM(vehicleClass_Agriculture) + SUM(vehicleClass_others)),2) AS 'Other Vehicles Percentage'


FROM
		fact_transport ft
JOIN
		dim_districts ds ON ds.dist_code = ft.dist_code
JOIN
		dim_date dd ON dd.month = ft.month
WHERE
		fiscal_year = 2022
GROUP BY
		district

-- Q7 List down the top 3 and bottom 3 districts that have shown the highest and lowest vehicle sales growth during FY 2022 compared to FY 2021? (Consider and compare categories: Petrol, Diesel and Electric)
WITH Top_Growth AS (
    SELECT
			district AS Districts,
			ROUND(CAST((SUM(CASE WHEN fiscal_year = 2022 THEN fuel_type_petrol ELSE 0 END) - SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_petrol ELSE 0 END)) * 100.0 AS FLOAT)/ NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_petrol ELSE 0 END), 0), 2) AS 'Petrol Growth (%)',
			ROUND(CAST((SUM(CASE WHEN fiscal_year = 2022 THEN fuel_type_diesel ELSE 0 END) - SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_diesel ELSE 0 END)) * 100.0 AS FLOAT)/ NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_diesel ELSE 0 END), 0), 2) AS 'Diesel Growth (%)',
			ROUND(CAST((SUM(CASE WHEN fiscal_year = 2022 THEN fuel_type_electric ELSE 0 END) - SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_electric ELSE 0 END)) * 100.0 AS FLOAT)/ NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_electric ELSE 0 END), 0), 2) AS 'Electric Growth (%)',
			ROUND(CAST((SUM(CASE WHEN fiscal_year = 2022 THEN fuel_type_petrol + fuel_type_diesel + fuel_type_electric ELSE 0 END) - SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_petrol + fuel_type_diesel + fuel_type_electric ELSE 0 END))*100.0 AS FLOAT) / NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_electric + fuel_type_diesel + fuel_type_petrol ELSE 0 END),0),2) AS 'total_growth (%)',
			'Top' AS position
	FROM
			fact_transport ft
    JOIN
			dim_date dd ON dd.month = ft.month
    JOIN
			dim_districts ds ON ds.dist_code = ft.dist_code
    GROUP BY
			district
	ORDER BY 
			[total_growth (%)] DESC OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY
),
Bottom_Growth AS (
    SELECT
			district AS Districts,
			ROUND(CAST((SUM(CASE WHEN fiscal_year = 2022 THEN fuel_type_petrol ELSE 0 END) - SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_petrol ELSE 0 END)) * 100.0 AS FLOAT)/ NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_petrol ELSE 0 END), 0), 2) AS 'Petrol Growth (%)',
			ROUND(CAST((SUM(CASE WHEN fiscal_year = 2022 THEN fuel_type_diesel ELSE 0 END) - SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_diesel ELSE 0 END)) * 100.0 AS FLOAT)/ NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_diesel ELSE 0 END), 0), 2) AS 'Diesel Growth (%)',
			ROUND(CAST((SUM(CASE WHEN fiscal_year = 2022 THEN fuel_type_electric ELSE 0 END) - SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_electric ELSE 0 END)) * 100.0 AS FLOAT)/ NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_electric ELSE 0 END), 0), 2) AS 'Electric Growth (%)',
			ROUND(CAST((SUM(CASE WHEN fiscal_year = 2022 THEN fuel_type_petrol + fuel_type_diesel + fuel_type_electric ELSE 0 END)- SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_petrol + fuel_type_diesel + fuel_type_electric ELSE 0 END))*100.0 AS FLOAT) / NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN fuel_type_electric + fuel_type_diesel + fuel_type_petrol ELSE 0 END),0),2) AS 'total_growth (%)',
			'Bottom' AS position
	FROM
			fact_transport ft
    JOIN
			dim_date dd ON dd.month = ft.month
    JOIN
			dim_districts ds ON ds.dist_code = ft.dist_code
    GROUP BY
			district
	ORDER BY 
			[total_growth (%)] ASC OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY
)

SELECT * FROM Top_Growth
UNION ALL
SELECT * FROM Bottom_Growth

-- Ts-Ipass (Telangana State Industrial Project Approval and Self Certification System)
-- Q8. List down the top 5 sectors that have witnessed the most significant investments in FY 2022.
SELECT
		sector AS Sector,
		SUM(investment_in_cr) AS 'Investment (Cr)'
FROM
		fact_TS_iPASS
WHERE
		YEAR(month) = 2022
GROUP BY
		sector
ORDER BY
		[Investment (Cr)] DESC OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY

-- Q9 List down the top 3 districts that have attracted the most significant sector investments during FY 2019 to 2022? What factors could have led to the substantial investments in these particular districts?
SELECT
		district AS Districts,
		SUM(investment_in_cr) AS Investments
FROM
		fact_TS_iPASS ftp
JOIN
		dim_date dd ON dd.month = ftp.month
JOIN
		dim_districts ds ON ds.dist_code = ftp.dist_code
WHERE
		fiscal_year IN (2019,2020,2021,2022)
GROUP BY
		district
ORDER BY
		Investments DESC OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY

-- Q10 Is there any relationship between sector investments, vehicles sales and stamps revenue in the same district between FY 2021 and 2022

SELECT
		district AS Districts,
		ROUND(SUM(CASE WHEN fiscal_year = 2021 THEN investment_in_cr END),2) AS 'Investment In 2021',
		ROUND(SUM(CASE WHEN fiscal_year = 2022 THEN investment_in_cr END),2) AS 'Investment In 2022',
		ROUND((SUM(CASE WHEN fiscal_year = 2022 THEN investment_in_cr END) - SUM(CASE WHEN fiscal_year = 2021 THEN investment_in_cr END)) / NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN investment_in_cr END), 0) * 100, 2) AS 'Investment Growth %',
		SUM(CASE WHEN fiscal_year = 2021 THEN vehicleClass_MotorCycle + vehicleClass_MotorCar + vehicleClass_AutoRickshaw + vehicleClass_Agriculture + vehicleClass_others END) AS total_vehicles_2021,
		SUM(CASE WHEN fiscal_year = 2022 THEN vehicleClass_MotorCycle + vehicleClass_MotorCar + vehicleClass_AutoRickshaw + vehicleClass_Agriculture + vehicleClass_others END) AS total_vehicles_2022,
		ROUND((SUM(CASE WHEN fiscal_year = 2022 THEN vehicleClass_MotorCycle + vehicleClass_MotorCar + vehicleClass_AutoRickshaw + vehicleClass_Agriculture + vehicleClass_others END)- SUM(CASE WHEN fiscal_year = 2021 THEN vehicleClass_MotorCycle + vehicleClass_MotorCar + vehicleClass_AutoRickshaw + vehicleClass_Agriculture + vehicleClass_others END))/ NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN vehicleClass_MotorCycle + vehicleClass_MotorCar + vehicleClass_AutoRickshaw + vehicleClass_Agriculture + vehicleClass_others END), 0) * 100.0,2) AS 'Vehicle Growth %',
		ROUND(SUM(CASE WHEN fiscal_year = 2021 THEN documents_registered_rev + estamps_challans_rev END),2)/10000000 AS 'Stamp Revenue (Cr)_2021',
		ROUND(SUM(CASE WHEN fiscal_year = 2022 THEN documents_registered_rev + estamps_challans_rev END),2)/10000000 AS 'Stamp Revenue (Cr)_2022',
		ROUND((SUM(CASE WHEN fiscal_year = 2022 THEN documents_registered_rev + estamps_challans_rev END)/10000000-SUM(CASE WHEN fiscal_year = 2021 THEN documents_registered_rev + estamps_challans_rev END)/1000000)/NULLIF(SUM(CASE WHEN fiscal_year = 2021 THEN documents_registered_rev + estamps_challans_rev END)/10000000,0)*100.0,2) AS 'Stamp Revenue Grwoth %'

FROM
		fact_TS_iPASS ftp
JOIN
		dim_date dd ON dd.month = ftp.month
JOIN
		dim_districts ds ON ds.dist_code = ftp.dist_code
JOIN
		fact_stamps fs ON fs.dist_code = ftp.dist_code
JOIN
		fact_transport ft ON ft.month = ftp.month
GROUP BY
		district

--Q11 Are there any particular sectors that have shown substantial growth in multiple districts in FY 2022?
SELECT
		district AS Districts,
		sector,
		CASE WHEN NTILE(3) OVER (ORDER BY SUM(investment_in_cr) DESC)=1 THEN SUM(investment_in_cr) END AS 'High Investment',
		CASE WHEN NTILE(3) OVER (ORDER BY SUM(investment_in_cr) DESC)=2 THEN SUM(investment_in_cr) END AS 'Medium Investment',
		CASE WHEN NTILE(3) OVER (ORDER BY SUM(investment_in_cr) DESC)=3 THEN SUM(investment_in_cr) END AS 'Low Investment'

FROM
		fact_TS_iPASS ftp
JOIN
		dim_districts ds ON ds.dist_code = ftp.dist_code
WHERE
		YEAR(month) = 2022
GROUP BY
		district,
		sector

-- Q12 Can we identify any seasonal patterns or cyclicality in the investment trends for specific sectors? Do certain sectors experience higher investments during particular months?
SELECT
		sector,
		DATENAME(month, ftp.month) AS 'Month',
		YEAR(ftp.month) AS 'Year',
		SUM(ftp.investment_in_cr) AS Investment,
		LAG(SUM(ftp.investment_in_cr), 1) OVER (PARTITION BY sector, DATENAME(month, ftp.month) ORDER BY YEAR(ftp.month)) AS Prev_Year_Investment,
		CASE WHEN LAG(SUM(ftp.investment_in_cr), 1) OVER (PARTITION BY sector, DATENAME(month, ftp.month) ORDER BY YEAR(ftp.month)) IS NOT NULL THEN SUM(ftp.investment_in_cr) - LAG(SUM(ftp.investment_in_cr), 1) OVER (PARTITION BY sector, DATENAME(month, ftp.month) ORDER BY YEAR(ftp.month)) ELSE NULL END AS Year_Over_Year_Change
FROM
		fact_TS_iPASS ftp
JOIN
		dim_date dd ON dd.month = ftp.month
GROUP BY
		sector,
		DATENAME(month, ftp.month),
		YEAR(ftp.month)
ORDER BY
		YEAR(ftp.month) DESC, DATENAME(month, ftp.month);

