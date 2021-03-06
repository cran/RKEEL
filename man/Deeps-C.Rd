\docType{class}
\name{Deeps_C}
\alias{Deeps_C}
\alias{R6_Deeps_C}
\title{Deeps_C KEEL Classification Algorithm}
\description{
Deeps_C Classification Algorithm from KEEL. 
}
\usage{
Deeps_C(train, test, beta)
}
\arguments{
\item{train}{Train dataset as a data.frame object}
\item{test}{Test dataset as a data.frame object}
\item{beta}{beta. Default value = 0.12}
}
\value{
A data.frame with the actual and predicted classes for both \code{train} and \code{test} datasets.
}
\examples{
#data_train <- RKEEL::loadKeelDataset("iris_train")
#data_test <- RKEEL::loadKeelDataset("iris_test")

#Create algorithm
#algorithm <- RKEEL::Deeps_C(data_train, data_test)

#Run algorithm
#algorithm$run()

#See results
#algorithm$testPredictions
}
\keyword{classification}

