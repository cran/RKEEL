\docType{class}
\name{ABB_IEP_FS}
\alias{ABB_IEP_FS}
\alias{R6_ABB_IEP_FS}
\title{ABB_IEP_FS KEEL Preprocess Algorithm}
\description{
ABB_IEP_FS Preprocess Algorithm from KEEL. 
}
\usage{
ABB_IEP_FS(train, test, seed)
}
\arguments{
\item{train}{Train dataset as a data.frame object}
\item{test}{Test dataset as a data.frame object}
\item{seed}{Seed for random numbers. If it is not assigned a value, the seed will be a random number}
}
\value{
A data.frame with the preprocessed data for both \code{train} and \code{test} datasets.
}
\examples{
#data_train <- RKEEL::loadKeelDataset("car_train")
#data_test <- RKEEL::loadKeelDataset("car_test")

#Create algorithm
#algorithm <- RKEEL::ABB_IEP_FS(data_train, data_test)

#Run algorithm
#algorithm$run()

#See results
#algorithm$preprocessed_test
}
\keyword{preprocess}

