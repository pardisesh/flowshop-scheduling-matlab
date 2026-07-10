-- Create database (optional if you already made it)
IF DB_ID('BikeDB') IS NULL
    CREATE DATABASE BikeDB;
GO
USE BikeDB;
GO

-- Create schema if missing
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dibris_bike')
    EXEC('CREATE SCHEMA dibris_bike');
GO

-- Drop & recreate tables for a clean start (optional)
IF OBJECT_ID('dibris_bike.ScheduleStep','U') IS NOT NULL DROP TABLE dibris_bike.ScheduleStep;
IF OBJECT_ID('dibris_bike.ScheduleRun','U')  IS NOT NULL DROP TABLE dibris_bike.ScheduleRun;
IF OBJECT_ID('dibris_bike.CutTube','U')      IS NOT NULL DROP TABLE dibris_bike.CutTube;
GO

-- Tubes in the accumulation input area
CREATE TABLE dibris_bike.CutTube (
    tube_id     INT IDENTITY(1,1) PRIMARY KEY,
    batch_id    INT           NOT NULL,
    p_welding   INT           NOT NULL,
    p_oven      INT           NOT NULL,
    CONSTRAINT CK_CutTube_Times CHECK (p_welding >= 0 AND p_oven >= 0)
);

-- A schedule "header"
CREATE TABLE dibris_bike.ScheduleRun (
    schedule_id INT IDENTITY(1,1) PRIMARY KEY,
    batch_id    INT           NOT NULL,
    algo        VARCHAR(50)   NOT NULL,
    created_at  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    makespan    INT           NOT NULL
);

-- The detailed sequence & timing
CREATE TABLE dibris_bike.ScheduleStep (
    step_id     INT IDENTITY(1,1) PRIMARY KEY,
    schedule_id INT NOT NULL FOREIGN KEY REFERENCES dibris_bike.ScheduleRun(schedule_id),
    seq_pos     INT NOT NULL,         -- position in sequence (1..n)
    tube_id     INT NOT NULL FOREIGN KEY REFERENCES dibris_bike.CutTube(tube_id),
    s1          INT NOT NULL,         -- start on machine 1 (welding)
    f1          INT NOT NULL,
    s2          INT NOT NULL,         -- start on machine 2 (oven)
    f2          INT NOT NULL
);
