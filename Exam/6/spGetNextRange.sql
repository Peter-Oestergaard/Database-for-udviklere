USE [ParcelNumbers]
GO
/****** Object:  StoredProcedure [dbo].[spGetNextRange]    Script Date: 04/11/2024 13.48.51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[spGetNextRange]
        @CustomerId NVARCHAR(32),
        @Amount INT
    AS
    BEGIN
        SET NOCOUNT ON;
        -- Without this check the current number at head would be returned and head would be increased by 0.
        -- That could lead to ambiguity about whether or not the number could be used for a label. Better
        -- return nothing to make it clear nothing was requested.
        IF @Amount = 0
    BEGIN
            RETURN;
    END;
        DECLARE @NumberBase BIGINT;
        DECLARE @ChosenRangeId NVARCHAR(32);
    BEGIN TRY
    BEGIN TRANSACTION
                SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    WITH RangesWithFreeAmount AS (
        SELECT *, ROW_NUMBER() OVER (
                ORDER BY
                CASE
                    -- Make sure that customer number ranges take precedence over shared
                    WHEN CustomerId LIKE @CustomerId + '\_%' ESCAPE '\' THEN 0
                    ELSE 1
                END,
                CustomerId
            ) as RowNum
        FROM NumberRange WITH (UPDLOCK, HOLDLOCK)
        WHERE (CustomerId LIKE @CustomerId + '\_%' ESCAPE '\' OR CustomerId LIKE '#shared\_%' ESCAPE '\')
          AND (High - Low + 1) > Head -- Only consider non depleted ranges
          AND (High - Low + 1 - Head) >= @Amount -- Only consider ranges with at least @Amount left
    )
    SELECT @ChosenRangeId = CustomerId FROM RangesWithFreeAmount WHERE RowNum = 1
    -- If no suitable range is found, exit
    IF @ChosenRangeId IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN;
    END
    -- Get the number to return before the table is updated
    SELECT @NumberBase = Low + Head FROM NumberRange WHERE CustomerId = @ChosenRangeId
    UPDATE NumberRange
    SET Head = Head + @Amount
    WHERE CustomerId = @ChosenRangeId
    SELECT @NumberBase AS NumberBase, @ChosenRangeId AS CustomerId
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
    IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW
    END CATCH;
END;