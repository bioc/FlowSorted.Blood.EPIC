% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/IDOLOptimizedCpGs.R
\docType{data}
\name{IDOLOptimizedCpGs}
\alias{IDOLOptimizedCpGs}
\title{IDOL Optimized CpGs for adult blood DNA methylation deconvolution EPIC}
\format{
An object of class "character" of length 450.

        The format is:
        chr [1:450] "cg08769189" "cg07661835" "cg00219921" "cg13468685" ...
}
\usage{
IDOLOptimizedCpGs
}
\description{
This object is a vector of length 450 consisting of the names of the IDOL
    optimized CpGs.  These CpGs are used as the backbone for deconvolution
    and were selected because their methylation signature differs across the
    six normal leukocyte subtypes.
}
\examples{
# Do not run
# head(IDOLOptimizedCpGs)
}
\references{
LA Salas et al. (2018). \emph{An optimized library for
reference-based deconvolution of whole-blood biospecimens assayed using the
Illumina HumanMethylationEPIC BeadArray}. Genome Biology 19, 64. doi:
\href{https://dx.doi.org/10.1186/s13059-018-1448-7}{10.1186/s13059-018-1448-7}

DC Koestler et al. (2016). \emph{Improving cell mixture
deconvolution by identifying optimal DNA methylation libraries (IDOL)}.
BMC bioinformatics. 17, 120. doi:
\href{https://dx.doi.org/10.1186/s13059-018-1448-7}{10.1186/s13059-018-1448-7}.
}
\keyword{datasets}
