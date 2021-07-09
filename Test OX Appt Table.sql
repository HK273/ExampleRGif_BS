DECLARE @SD DATETIME = '2006-01-01 00:00:00.000' -- 1st January 2006
DECLARE @ED DATETIME = '2020-12-31 23:59:00.000' --  31st December 2020


DROP TABLE IF EXISTS BI_Reporting_Dev.dbo.tbl_testhkappt
---Needs a  CTE / sub query to group the month-year outputs correctly--
;WITH CTE AS
(
SELECT DISTINCT
A.TeamCodeDescription
,O.Directorate
--,CONCAT(DATENAME(MONTH,A.AppointmentDate),'-',YEAR(A.AppointmentDate)) AS [Month-Year-Appointment]
,YEAR(A.AppointmentDate) AS [Year-Appointment]
,SUM (CASE WHEN A.AppointmentDate IS NOT NULL THEN 1 ELSE 0 END) AS Total_Appointments
,SUM (CASE WHEN A.OutcomeGrouped = '1.Attended' THEN 1 ELSE 0 END) AS Attended
,SUM (CASE WHEN A.OutcomeGrouped = '2.DNA' THEN 1 ELSE 0 END) AS DNA
,SUM (CASE WHEN A.OutcomeGrouped = '4.No Outcome' THEN 1 ELSE 0 END) AS [No Outcome]
,SUM (CASE WHEN A.OutcomeGrouped = '3c.Cancellation (Error)' THEN 1 ELSE 0 END) AS [Cancellation (Error)]
,SUM (CASE WHEN A.OutcomeGrouped = '3a.Cancellation (Client)' THEN 1 ELSE 0 END) AS [Cancellation (Client)]
,SUM (CASE WHEN A.OutcomeGrouped = '3b.Cancellation (Provider)' THEN 1 ELSE 0 END) AS [Cancellation (Provider)]
,SUM (CASE WHEN A.OutcomeGrouped = '3d.Cancellation (Unclassified)' THEN 1 ELSE 0 END) AS [Cancellation (Unclassified)]
,SUM (CASE WHEN A.OutcomeGrouped = '6.No Outcome - Future Appointment' THEN 1 ELSE 0 END) AS [No Outcome - Future Appointment]
FROM BI_Reporting.dbo.tbl_Appointment AS A

---Add in New OrgStructure Info----------------
OUTER APPLY(SELECT TOP 1 O.Borough
				,O.Directorate
FROM BI_OrgStructureNew.dbo.OrgUnitsFlat AS O
WHERE O.Rio_TeamCode = A.TeamCode
AND O.UnitType = 'Team'
AND O.DirectorateCode != 'TEST' -- Remove TEST teams
)AS O
-------------------------------------------------

WHERE A.AppointmentDate BETWEEN @SD AND @ED
AND A.DirectorateCode != 'TEST' -- Remove TEST teams
AND A.TeamCodeDescription != 'No Team' -- What is this team? used for some clinics that are set up to not require a referral
--AND A.TeamCodeDescription = 'Bexley MSK' -- Check

GROUP BY
A.TeamCodeDescription
,O.Directorate
,A.AppointmentDate
)

SELECT DISTINCT 
	C.Directorate AS [name]
	,[Year-Appointment] AS [year]
	,SUM (C.Total_Appointments) AS [n] -- Number
	INTO BI_Reporting_Dev.dbo.tbl_testhkappt
FROM CTE AS C

GROUP BY c.[Year-Appointment]
,C.Directorate
,C.TeamCodeDescription
ORDER BY C.[Year-Appointment]

SELECT T.name
	,SUM(T.N) AS n
	,T.year
FROM BI_Reporting_Dev.dbo.tbl_testhkappt AS T
WHERE T.name IS NOT NULL
GROUP BY T.year
,T.name
ORDER BY T.year ASC


