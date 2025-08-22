/*
==================================
 Crear la base de dato y esquemas
==================================

Propósito del script:
	Este script crea una nueva base de datos llamado 'DataWarehouse' después de verificar si ya existe.
	Si la base de datos ya existe, entonces es eliminado y vuelvo a crear. Adicionalmente, el script define 3 esquemas en la base de datos: 'bronze', 
	'silver' y 'gold'.

WARNING:
	Al ejecutar el script se eliminará la base de datos 'DataWarehouse' por completo si ya existe.
	Toda la data de la base de datos será eliminada permanentemente. Usa el script con cuidado y asegurate de tener backups antes de la ejecución.
*/


USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	/* Esto sirve para forzar que ningún otro proceso/usuario esté conectado a ella.
	El WITH ROLLBACK IMMEDIATE hace que cualquier transacción abierta se cierre y se revierta inmediatamente para que se pueda continuar con la operación.*/
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

	DROP DATABASE DataWarehouse;
END;
GO

-- Crear la base de datos 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Crear los esquemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
