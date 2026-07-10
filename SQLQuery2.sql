IF DB_ID('BikeDB') IS NULL CREATE DATABASE BikeDB;
GO
USE BikeDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='dibris_bike')
    EXEC('CREATE SCHEMA dibris_bike');
GO

IF OBJECT_ID('dibris_bike.ScheduleStep','U') IS NOT NULL DROP TABLE dibris_bike.ScheduleStep;
IF OBJECT_ID('dibris_bike.ScheduleRun','U')  IS NOT NULL DROP TABLE dibris_bike.ScheduleRun;
IF OBJECT_ID('dibris_bike.CutTube','U')      IS NOT NULL DROP TABLE dibris_bike.CutTube;
GO

CREATE TABLE dibris_bike.CutTube (
    tube_id     INT IDENTITY(1,1) PRIMARY KEY,
    batch_id    INT NOT NULL,
    p_welding   INT NOT NULL,
    p_oven      INT NOT NULL,
    CONSTRAINT CK_CutTube_Times CHECK (p_welding >= 0 AND p_oven >= 0)
);
CREATE INDEX IX_CutTube_Batch ON dibris_bike.CutTube(batch_id);

CREATE TABLE dibris_bike.ScheduleRun (
    schedule_id INT IDENTITY(1,1) PRIMARY KEY,
    batch_id    INT NOT NULL,
    algo        VARCHAR(50) NOT NULL,      -- 'Johnson' or 'MILP'
    created_at  DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    makespan    INT NOT NULL
);

CREATE TABLE dibris_bike.ScheduleStep (
    step_id     INT IDENTITY(1,1) PRIMARY KEY,
    schedule_id INT NOT NULL FOREIGN KEY REFERENCES dibris_bike.ScheduleRun(schedule_id),
    seq_pos     INT NOT NULL,
    tube_id     INT NOT NULL FOREIGN KEY REFERENCES dibris_bike.CutTube(tube_id),
    s1          INT NOT NULL,  f1 INT NOT NULL,
    s2          INT NOT NULL,  f2 INT NOT NULL
);
