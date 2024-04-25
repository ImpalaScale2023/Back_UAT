ALTER PROCEDURE [dbo].[Weighing_Guide_Update]
@IdCompany INT,
@IdCompanyBranch INT,
@IdWeighing INT,
@Guide VARCHAR(20),
@IdMotivoTraslado INT,
@IdTransferModality INT,
@IdCompanyAud INT,
@IdUserAud INT,
@Error VARCHAR(MAX) OUTPUT
AS
BEGIN TRAN
BEGIN TRY
	--DECLARE @IdCompanyBranch INT
	IF EXISTS (SELECT 1 FROM Weighing WHERE IdCompanyBranch = @IdCompanyBranch AND IdWeighing = @IdWeighing AND ISNULL(GuideNumber, '') = '')
	BEGIN
		SET @Error = '1'
	END

	--SELECT @IdCompanyBranch = IdCompanyBranch FROM Weighing WHERE IdWeighing = @IdWeighing
	IF @Guide = '' BEGIN
		DECLARE @Serie VARCHAR(5),
				@Correlativo VARCHAR(8),
				@Correlativo_I INT,
				@IdClient INT

		SELECT
		@Serie = ISNULL(cl.Serie, ''), 
		@Correlativo = RIGHT(CONCAT('00000000', ISNULL(cl.Correlative, 0) + 1), 8),
		@Correlativo_I = ISNULL(cl.Correlative, 0) + 1,
		@IdClient = cl.IdClient
		FROM Weighing we
		INNER JOIN Client cl ON cl.IdCompany = we.IdCompany AND cl.IdClient = we.IdClient
		WHERE we.IdCompany = @IdCompany AND we.IdWeighing = @IdWeighing
		
		IF @Serie = ''
		BEGIN
			--SET @Error = '#VALID!' + 'The GuideNumber already exists'
			;THROW 50002, '#VALID! The series is empty, add in client', 1
		END

		UPDATE Weighing SET
		GuideNumber = (SELECT CONCAT(@Serie, '-', @Correlativo)),
		IdMotivoTraslado = @IdMotivoTraslado,
		IdTransferModality = @IdTransferModality,
		UpdatedIdUser = @IdUserAud,
		UpdatedIdCompany = @IdCompanyAud,
		UpdatedDate = dbo.FechaUTC(@IdCompany, @IdCompanyBranch)
		WHERE IdCompany = @IdCompany
		AND IdCompanyBranch = @IdCompanyBranch 
		AND IdWeighing = @IdWeighing
		AND DeletedFlag = 0

		SET @Guide = (SELECT CONCAT(@Serie, '-', @Correlativo))

		UPDATE Client SET
		Correlative = @Correlativo,
		UpdatedIdUser = @IdUserAud,
		UpdatedIdCompany = @IdCompanyAud,
		UpdatedDate = dbo.FechaUTC(@IdCompany, @IdCompanyBranch)
		WHERE IdCompany = @IdCompany
		AND IdCompanyBranch = @IdCompanyBranch 
		AND IdClient = @IdClient
		AND DeletedFlag = 0

	END
	ELSE
	BEGIN
		UPDATE Weighing SET
		GuideNumber = @Guide,
		IdMotivoTraslado = @IdMotivoTraslado,
		UpdatedIdUser = @IdUserAud,
		UpdatedIdCompany = @IdCompanyAud,
		UpdatedDate = dbo.FechaUTC(@IdCompany, @IdCompanyBranch)
		WHERE IdCompany = @IdCompany
		AND IdCompanyBranch = @IdCompanyBranch 
		AND IdWeighing = @IdWeighing
		AND DeletedFlag = 0
	END
	
	IF (SELECT COUNT(*) FROM Weighing WHERE IdCompany = @IdCompany
		AND GuideNumber = @Guide AND DeletedFlag = 0) > 1
	BEGIN
        --SET @Error = '#VALID!' + 'The GuideNumber already exists'
		;THROW 50002, '#VALID! The GuideNumber already exists', 1
	END
	--ELSE
	--BEGIN
	--	SET @Error = ''
	--END

COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	SET @Error = CONCAT('Línea N°', ERROR_LINE(), ': ', ERROR_MESSAGE())
END CATCH

