#' projectCellType_CP
#'
#' @description    This function predicts the underlying cellular composition of
#' heterogeneous tissue  types (i.e., WB) using the constrained projection
#' procedure described by
#' \href{https://dx.doi.org/10.1186/s12859-016-0943-7}{Houseman et al. 2012}.
#' This is equivalent to the internal projectCellType function in minfi,
#' \href{https://dx.doi.org/10.1186/gb-2014-15-2-r31}{Jaffe et al. 2014}. We
#' recommend this function only for advanced users. Please preprocess your
#' dataset filtering potential bad quality samples.
#'
#' @import    quadprog
#' @examples
#' # Step 1: Load the reference library to extract the artificial mixtures
#' FlowSorted.Blood.EPIC <- libraryDataGet("FlowSorted.Blood.EPIC")
#' FlowSorted.Blood.EPIC
#'
#' # Step 2 separate the reference from the testing dataset if you want to run
#' # examples for estimations for this function example
#'
#' RGsetTargets <- FlowSorted.Blood.EPIC[
#'     ,
#'     FlowSorted.Blood.EPIC$CellType == "MIX"
#' ]
#'
#' sampleNames(RGsetTargets) <- paste(RGsetTargets$CellType,
#'     seq_len(dim(RGsetTargets)[2]),
#'     sep = "_"
#' )
#' RGsetTargets
#'
#' # Step 3: apply the CP approach using the preloaded matrix of IDOL.
#' # Deconvolute a target data set consisting of EPIC DNA methylation
#' # data profiled in blood, using your prefered method.
#'
#' # You can use our IDOL optimized DMR library for the EPIC array.  This object
#' # contains a matrix of dimensions 450 X 6 consisting on average methylation
#' # values obtained from the IDs of the IDOL optimized CpG probes.  These
#' # CpGs are used as the backbone for deconvolution and were selected because
#' # their methylation signature differs across the six normal leukocyte
#' # subtypes.
#'
#' head(IDOLOptimizedCpGs.compTable)
#' # If you need to deconvolute a 450k legacy dataset use
#' # IDOLOptimizedCpGs450klegacy.compTable instead
#'
#' # We recommend using Noob processMethod = "preprocessNoob" in minfi for the
#' # target and reference datasets.
#' # Cell types included are "CD8T", "CD4T", "NK", "Bcell", "Mono", "Neu"
#'
#' # If you need to normalize your data do not run with limited RAM. The
#' # normalization step requires a big amount of memory resources
#'
#' if (memory.limit() > 8000) {
#'     propEPIC <- projectCellType_CP(
#'         getBeta(preprocessNoob(RGsetTargets))[IDOLOptimizedCpGs, ],
#'         IDOLOptimizedCpGs.compTable,
#'         contrastWBC = NULL, nonnegative = TRUE,
#'         lessThanOne = FALSE
#'     )
#'
#'     head(propEPIC)
#'     percEPIC <- round(propEPIC * 100, 1)
#' }
#' @param
#' Y  A J x N matrix of methylation beta-values collected from mixed/
#'    heterogeneous biospecimen (i.e., Whole Blood).  Target set.
#'
#' @param
#' coefWBC A J x K projection matrix;, i.e., within-cell type mean methylation
#'     matrix across J L-DMRs and K number of cell types
#'
#' @param
#' contrastWBC Contrast for cell composition predictions set to NULL by
#'               default. The user should not modify this
#'
#' @param
#' nonnegative Should cell predictions be nonnegative.  Defaults to TRUE
#'
#' @param
#' lessThanOne Should the predictions sum less than one. Default is FALSE
#'
#' @return
#' A N x K matrix of cell proportion estimates across the K cell types for each
#' of the N subjects contained in the Target Set.
#'
#' @export



projectCellType_CP <- function(Y, coefWBC, contrastWBC = NULL,
                            nonnegative = TRUE, lessThanOne = FALSE) {
    if (is.null(contrastWBC)) {
        Xmat <- coefWBC
    } else {
        Xmat <- tcrossprod(coefWBC, contrastWBC)
    }
    nCol <- dim(Xmat)[2]
    if (nCol == 2) {
        Dmat <- crossprod(Xmat)
        mixCoef <- t(apply(Y, 2, function(x) {
            solve(Dmat, crossprod(Xmat, x))
        }))
        colnames(mixCoef) <- colnames(Xmat)
        return(mixCoef)
    } else {
        nSubj <- dim(Y)[2]
        mixCoef <- matrix(0, nSubj, nCol)
        rownames(mixCoef) <- colnames(Y)
        colnames(mixCoef) <- colnames(Xmat)
        if (nonnegative) {
            if (lessThanOne) {
                Amat <- cbind(rep(-1, nCol), diag(nCol))
                b0vec <- c(-1, rep(0, nCol))
            } else {
                Amat <- diag(nCol)
                b0vec <- rep(0, nCol)
            }
            for (i in seq_len(nSubj)) {
                obs <- which(!is.na(Y[, i]))
                Dmat <- crossprod(Xmat[obs, ])
                mixCoef[i, ] <- round(solve.QP(
                    Dmat, crossprod(
                        Xmat[obs, ],
                        Y[obs, i]
                    ),
                    Amat, b0vec
                )$sol, 4)
            }
        } else {
            for (i in seq_len(nSubj)) {
                obs <- which(!is.na(Y[, i]))
                Dmat <- crossprod(Xmat[obs, ])
                mixCoef[i, ] <- round(solve(Dmat, t(Xmat[obs, ]) %*% Y[obs, i]), 4)
            }
        }
        return(mixCoef)
    }
}
