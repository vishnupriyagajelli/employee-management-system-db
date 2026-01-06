create database emp_mange_Sy;
use emp_mange_sy;


-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from emp_mange_Sy.JobDepartment;


-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from emp_mange_Sy.SalaryBonus;


-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
select * from emp_mange_Sy.Employee;


-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from emp_mange_Sy.Qualification;


-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from emp_mange_Sy.Leaves;



-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from emp_mange_Sy.Payroll;


-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
SELECT COUNT(DISTINCT emp_ID) AS total_employees
FROM Employee;

-- Which departments have the highest number of employees?
SELECT jd.JobDept, COUNT(e.emp_ID) AS Total_employees
FROM Employee e
JOIN JobDepartment jd
    ON e.Job_ID = jd.Job_ID
GROUP BY jd.JobDept
ORDER BY Total_Employees DESC;

-- What is the average salary per department?
SELECT jd.JobDept, AVG(sb.Amount) AS Avg_Salary
FROM SalaryBonus sb
JOIN JobDepartment jd
    ON sb.Job_ID = jd.Job_ID
GROUP BY jd.JobDept
ORDER BY Avg_Salary DESC;

-- Who are the top 5 highest-paid employees?
SELECT e.emp_ID, e.FirstName, e.LastName, p.total_amount
FROM Payroll p
JOIN Employee e ON p.emp_ID = e.emp_ID
ORDER BY p.total_amount DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT SUM(Total_Amount) AS Total_Company_Expenditure
FROM Payroll;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
SELECT jobdept, COUNT(*) AS total_job_roles
FROM JobDepartment
GROUP BY jobdept
ORDER BY total_job_roles DESC;

-- What is the average salary range per department?
SELECT jd.jobdept, AVG(sb.Amount) AS avg_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY avg_salary DESC;


-- Which job roles offer the highest salary?
SELECT jd.Name AS JobRole, jd.jobdept, sb.Amount
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
ORDER BY sb.Amount DESC
LIMIT 5;


-- Which departments have the highest total salary allocation?
SELECT jd.jobdept, SUM(sb.Amount) AS total_department_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_department_salary DESC;


-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS Employees_With_Qualifications
FROM Qualification;


-- Which positions require the most qualifications?
SELECT jd.Name AS JobRole,
       COUNT(q.QualID) AS Total_Qualifications
FROM Qualification q
JOIN Employee e ON q.Emp_ID = e.Emp_ID
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.Name
ORDER BY Total_Qualifications DESC;

-- Which employees have the highest number of qualifications?
SELECT e.Emp_ID, e.firstName, e.lastName,
       COUNT(q.QualID) AS Qualification_Count
FROM Qualification q
JOIN Employee e ON q.Emp_ID = e.Emp_ID
GROUP BY e.Emp_ID, e.firstName, e.lastName
ORDER BY Qualification_Count DESC;

-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
SELECT YEAR(date) AS Leave_Year,
       COUNT(DISTINCT Emp_ID) AS Employees_Took_Leave
FROM Leaves
GROUP BY YEAR(date)
ORDER BY Employees_Took_Leave DESC;

-- What is the average number of leave days taken by its employees per department?
SELECT jd.jobdept AS Department,
       AVG(leave_count) AS Avg_Leave_Days
FROM (
    SELECT e.Job_ID, e.Emp_ID, COUNT(*) AS leave_count
    FROM Leaves l
    JOIN Employee e ON l.Emp_ID = e.Emp_ID
    GROUP BY e.Emp_ID, e.Job_ID
) emp_leaves
JOIN JobDepartment jd ON emp_leaves.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY Avg_Leave_Days DESC;


-- Which employees have taken the most leaves?
SELECT e.Emp_ID, e.firstname, e.lastname,
       COUNT(*) AS Total_Leaves
FROM Leaves l
JOIN Employee e ON l.Emp_ID = e.Emp_ID
GROUP BY e.Emp_ID, e.firstname, e.lastname
ORDER BY Total_Leaves DESC
LIMIT 5;


-- What is the total number of leave days taken company-wide?
SELECT count(*) AS Total_Leave_Days_Company
FROM Leaves;

-- How do leave days correlate with payroll amounts?
SELECT e.Emp_ID, e.firstname, e.lastname,
       COUNT(l.Leave_ID) AS Total_Leave_Days,
       p.total_amount AS Payroll
FROM Employee e
LEFT JOIN Leaves l ON e.Emp_ID = l.Emp_ID
JOIN Payroll p ON e.Emp_ID = p.Emp_ID
GROUP BY e.Emp_ID, e.firstname, e.lastname, p.total_amount
ORDER BY Total_Leave_Days DESC;


-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
SELECT SUM(Total_Amount) AS Total_Monthly_Payroll
FROM Payroll;

-- What is the average bonus given per department?
SELECT jd.jobdept AS Department,
       AVG(sb.bonus) AS Avg_Bonus
FROM Payroll p
JOIN Employee e ON p.Emp_ID = e.Emp_ID
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus sb ON p.Salary_ID = sb.Salary_ID
GROUP BY jd.jobdept
ORDER BY Avg_Bonus DESC;


-- Which department receives the highest total bonuses?
SELECT jd.jobdept AS Department,
       SUM(sb.bonus) AS Total_Bonus
FROM Payroll p
JOIN Employee e ON p.Emp_ID = e.Emp_ID
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus sb ON p.Salary_ID = sb.Salary_ID
GROUP BY jd.jobdept
ORDER BY Total_Bonus DESC
LIMIT 1;

-- What is the average value of total_amount after considering leave deductions?
SELECT AVG(p.Total_Amount - IF(l.Leave_ID IS NOT NULL, sb.Amount/30, 0)) AS Avg_Total_After_Leave
FROM Payroll p
JOIN SalaryBonus sb ON p.Salary_ID = sb.Salary_ID
LEFT JOIN Leaves l ON p.Leave_ID = l.Leave_ID;



