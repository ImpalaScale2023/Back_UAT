-- EXEC dbo.ReWeighingWeight_Ticket 1, 200, 3, 2,2
ALTER PROCEDURE [dbo].[ReWeighingWeight_Ticket]
@IdCompany INT,
@TimeZone INT,
@IdReWeighing INT,
@IdReWeighingWeight INT,
@IdStatus INT
AS
DECLARE @IdCompanyBranch INT = (SELECT IdCompanyBranch FROM ReWeighingWeight 
														WHERE IdReWeighingWeight = @IdReWeighingWeight 
														AND IdReWeighing = @IdReWeighing)
DECLARE @FechaImpresion DATETIME = dbo.FechaUTC(@IdCompany, @IdCompanyBranch)
--DECLARE @IdWeighingCycle INT
--SELECT @IdWeighingCycle = IdWeighingCycle FROM Weighing WHERE IdCompany = @IdCompany AND IdWeighing = @IdWeighing

IF @IdStatus = 1
BEGIN
	SELECT
	CONCAT(CONVERT(VARCHAR(10), @FechaImpresion, 103), ' ', CONVERT(VARCHAR(8), DATEADD(MINUTE, @TimeZone, @FechaImpresion), 108)) AS FechaImpresion,
		FORMAT(DATEADD(MINUTE, @TimeZone, @FechaImpresion) , 'yyyyMMddHHmmss') AS FechaImpresion2,
	cb.CompanyBranch AS ImpalaTerminals,
	ve.TruckNumber AS TruckPlate,
	ve.TrailerNumber AS TrailerPlate,
	rw.Pila AS Pila,
	ISNULL(CONVERT(VARCHAR(10), rww.TareDate, 120), '') AS Fecha,
	ISNULL(CONVERT(VARCHAR(8), DATEADD(MINUTE, @TimeZone, rww.TareDate), 108), '') AS Hora,
	ve.TrailerNumber AS Carreta,
	rw.IdQuality,
	qu.[Description] AS Quality,
	ISNULL(rw.WMSReference, '') AS WMSReference,
	rw.IdProduct,
	pr.CodProduct AS Product,
	ISNULL(cl.BusinessName, '') AS Productor,
	'' AS Descarga,
	ISNULL(rww.[Sequence], 0) AS nrCamion,
	rww.Lot
	FROM ReWeighingWeight rww
	INNER JOIN CompanyBranch cb ON cb.IdCompany = rww.IdCompany AND cb.IdCompanyBranch = rww.IdCompanyBranch
	INNER JOIN ReWeighing rw ON rw.IdCompany = rww.IdCompany AND rw.IdCompanyBranch = rww.IdCompanyBranch AND rw.IdReWeighing = rww.IdReWeighing
	INNER JOIN Vehicle ve ON ve.IdCompany = rww.IdCompany AND ve.IdCompanyBranch = rww.IdCompanyBranch AND ve.IdVehicle = rww.IdVehicle
	INNER JOIN Quality qu ON qu.IdCompany = rww.IdCompany AND qu.IdCompanyBranch = rww.IdCompanyBranch AND qu.IdQuality = rw.IdQuality
	INNER JOIN Client cl ON cl.IdCompany = rww.IdCompany AND cl.IdCompanyBranch = rww.IdCompanyBranch AND cl.IdClient = rw.IdClient
	INNER JOIN Product pr ON pr.IdCompany = rww.IdCompany AND pr.IdCompanyBranch = rww.IdCompanyBranch AND pr.IdProduct = rw.IdProduct
	WHERE rww.IdCompany = @IdCompany 
		AND rww.IdReWeighingWeight = @IdReWeighingWeight 
		AND rww.IdReWeighing = @IdReWeighing
END
ELSE  IF @IdStatus = 2
BEGIN
	SELECT
	CONCAT(CONVERT(VARCHAR(10), @FechaImpresion, 103), ' ', CONVERT(VARCHAR(8), DATEADD(MINUTE, @TimeZone, @FechaImpresion), 108)) AS FechaImpresion,
	FORMAT(DATEADD(MINUTE, @TimeZone, @FechaImpresion) , 'yyyyMMddHHmmss') AS FechaImpresion2,
	cb.CompanyBranch AS ImpalaTerminals,
	'' AS Descarga,
	'Re-Peso' AS TypeOperation,
	ve.TruckNumber AS TruckPlate,
	ve.TrailerNumber AS TrailerPlate,
	rw.Pila AS Pila,
	rw.IdProduct,
	pr.DescProduct AS Product,
	ISNULL(cl.BusinessName, '') AS Productor,
	rw.IdQuality,
	qu.[Description] AS Quality,
	ISNULL(rw.WMSReference, '') AS WMSReference,
	rww.Obs,
	ISNULL(baI.Bascule, '') AS InputBascule,
	ISNULL(baO.Bascule, '') AS OutputBascule,
	ISNULL(CONVERT(VARCHAR(10), rww.GrossDate, 120), '') AS InputDate,
	ISNULL(CONVERT(VARCHAR(8), DATEADD(MINUTE, @TimeZone, rww.GrossDate), 108), '') AS InputHour,
	ISNULL(CONVERT(VARCHAR(10), rww.TareDate, 120), '') AS OutputDate,
	ISNULL(CONVERT(VARCHAR(8), DATEADD(MINUTE, @TimeZone, rww.TareDate), 108), '') AS OutputHour,
	rww.GrossWeight,
	rww.TareWeight,
	rww.NetWeight,
	ISNULL(rww.[Sequence], 0) AS nrCamion,
	rww.Lot
	FROM ReWeighingWeight rww
	INNER JOIN CompanyBranch cb ON cb.IdCompany = rww.IdCompany AND cb.IdCompanyBranch = rww.IdCompanyBranch
	INNER JOIN ReWeighing rw ON rw.IdCompany = rww.IdCompany AND rw.IdCompanyBranch = rww.IdCompanyBranch AND rw.IdReWeighing = rww.IdReWeighing
	INNER JOIN Vehicle ve ON ve.IdCompany = rww.IdCompany AND ve.IdCompanyBranch = rww.IdCompanyBranch AND ve.IdVehicle = rww.IdVehicle
	INNER JOIN Quality qu ON qu.IdCompany = rww.IdCompany AND qu.IdCompanyBranch = rww.IdCompanyBranch AND qu.IdQuality = rw.IdQuality
	INNER JOIN Client cl ON cl.IdCompany = rww.IdCompany AND cl.IdCompanyBranch = rww.IdCompanyBranch AND cl.IdClient = rw.IdClient
	INNER JOIN Product pr ON pr.IdCompany = rww.IdCompany AND pr.IdCompanyBranch = rww.IdCompanyBranch AND pr.IdProduct = rw.IdProduct
	LEFT JOIN Bascule baI ON baI.IdCompany = rww.IdCompany AND baI.IdCompanyBranch = rww.IdCompanyBranch AND baI.IdBascule = rww.InputIdBascule
	LEFT JOIN Bascule baO ON baO.IdCompany = rww.IdCompany AND baO.IdCompanyBranch = rww.IdCompanyBranch AND baO.IdBascule = rww.OutputIdBascule
	WHERE rww.IdCompany = @IdCompany 
		AND rww.IdReWeighingWeight = @IdReWeighingWeight 
		AND rww.IdReWeighing = @IdReWeighing
END
