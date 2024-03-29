#Class implementing the KeelAlgorithm
  #Implements the common functions of a KEEL classification algorithm

ClassificationAlgorithm <- R6::R6Class("ClassificationAlgorithm",

  inherit = KeelAlgorithm,

  public = list(

    #Public properties

    #Algorithm outputs
    output = NULL,
    trainPredictions = NULL,
    testPredictions = NULL,


    #Public functions

    #Initialize function
    setParameters = function(train, test){

      super$initialize()

      #Create dataset (.dat) files
      private$trainFilename <- "train.dat"
      private$testFilename <- "test.dat"

      #Assign datasets
      private$trainDataset <- train
      private$testDataset <- test

      #Test jar file
      if(! file.exists(paste0(private$exePath, private$jarName))){
        stop(paste0(private$jarName, " doesn't exist under the defined path. Installation error;", private$exePath, private$jarName))
      }

      private$dataName <- "data"
    },

    run = function(folderPath, expUniqueName, javaOptions){

      super$run(folderPath, expUniqueName, javaOptions)

      #Use tryCatch() to remove experiment folders even if there are errors
      tryCatch({

        #Create dataset folder
        dir.create(paste0(private$mainPath, "/datasets/", private$dataName))
        #Write dataset files
        writeDatFromDataframes(private$trainDataset, private$testDataset, paste0(private$mainPath, "/datasets/", private$dataName, "/", private$trainFilename), paste0(private$mainPath, "/datasets/", private$dataName, "/", private$testFilename))

        #Copy algorithm exe
        file.copy(system.file("exe", private$jarName, package = "RKEEL"), paste0(private$mainPath, "/exe/", private$jarName))

        #Create results dir
        dir.create(paste0(private$mainPath, "/results/", private$algorithmName, ".", private$dataName))

        #Create .xml experiment file
        private$writeKeelXML()

        #Create config files
        dir.create(paste0(private$mainPath, "/scripts/", private$algorithmName))
        dir.create(paste0(private$mainPath, "/scripts/", private$algorithmName, "/", private$dataName))
        private$writeKeelConfig()

        #Change work directory to execute .jar
        wdPath <- getwd()
        #Change to old current working directory after finishing the function
        # even if an error occurs
        on.exit(setwd(wdPath))

        setwd(paste0(private$mainPath, "/scripts/"))
        if(grepl("windows", tolower(Sys.info()[1]))) {
          system(paste0(private$javaPath, "java ", private$javaOpt, " -jar RunKeel.jar"), show.output.on.console = FALSE)
        }
        else {
          system(paste0(private$javaPath, "java ", private$javaOpt, " -jar RunKeel.jar"), ignore.stdout = TRUE)
        }
        setwd(wdPath)

        #read outputs
        private$readOutputs(paste0(private$mainPath, "/results/", private$algorithmName, ".", private$dataName, "/result0.tra"), paste0(private$mainPath, "/results/", private$algorithmName, ".", private$dataName, "/result0.tst"), paste0(private$mainPath, "/results/", private$algorithmName, ".", private$dataName, "/result0e0.txt"))

        if(missing(folderPath)){
          cat(paste0("Algorithm ",  class(self)[1], " executed successfully", sep="\n"))
        }
        else{
          cat(paste0("Algorithm ",  class(self)[1], " executed successfully. Stored in: ", private$mainPath, sep="\n"))
        }

      }, error = function(err) {
        #Error
        cat(paste0("Error! ",err))
      }, finally = {
        #Remove data files and Keel experiment folder
        if(missing(folderPath)){
          unlink(paste0(private$dataPath, private$trainFilename))
          unlink(paste0(private$dataPath, private$testFilename))
          unlink(private$mainPath, recursive = TRUE)
        }
      })

    },


    #Print object
    print = function() {

      if(class(self)[1] == "ClassificationAlgorithm") {
        cat("Keel Classification Algorithm Object", sep="\n")
        cat("Need to have an object of an algorithm implementing this class")
      }
      else {
        cat("-----------------------------------", "\n", sep="")
        cat(private$algorithmString, "\n", sep="")
        cat("-----------------------------------", "\n", sep="")
        cat(private$getParametersText(), sep="")
        cat("-----------------------------------", "\n", sep="")
      }

    }

  ),

  private = list(

    #train filename
    trainFilename = NULL,

    #test filename
    testFilename = NULL,

    #train dataset
    trainDataset = NULL,

    #test dataset
    testDataset = NULL,

    #dataset name
    dataName = NULL,

    #Create XML function
    writeKeelXML = function(){

      nodeExecution <- XML::xmlNode("execution")

      nodeSentence <- XML::xmlNode("sentence")
      nodeSentence <- XML::addChildren(nodeSentence, kids = list(XML::xmlNode("command", "java")))
      nodeSentence <- XML::addChildren(nodeSentence, kids = list(XML::xmlNode("option", "-Xmx512000000")))
      nodeSentence <- XML::addChildren(nodeSentence, kids = list(XML::xmlNode("option", "-jar")))
      nodeSentence <- XML::addChildren(nodeSentence, kids = list(XML::xmlNode("executableFile", paste0("../exe/", private$jarName))))
      nodeSentence <- XML::addChildren(nodeSentence, kids = list(XML::xmlNode("scriptFile", paste0("./", private$algorithmName, "/", private$dataName, "/config0s0", ".txt"))))
      nodeExecution <- XML::addChildren(nodeExecution, kids = list(nodeSentence))

      XML::saveXML(nodeExecution, paste0(private$mainPath, "/scripts/", "RunKeel.xml"))

    },


    #Create config files function
    writeKeelConfig = function(){

      #Ficheros de entrada
      inputDataString = paste0("\"../datasets/", private$dataName, "/", private$trainFilename, "\" \"../datasets/", private$dataName, "/", private$trainFilename, "\" \"../datasets/", private$dataName, "/", private$testFilename, "\"")
      #Ficheros de salida
      outputDataString = paste0("\"../results/", private$algorithmName, ".",private$dataName, "/result0", ".tra\" \"../results/", private$algorithmName, ".", private$dataName, "/result0", ".tst\" \"../results/", private$algorithmName, ".", private$dataName, "/result0", "e0.txt\"")

      text <- ""
      text <- paste0(text, "algorithm = ", private$algorithmString)
      text <- paste0(text, "\ninputData = ", inputDataString)
      text <- paste0(text, "\noutputData = ", outputDataString)
      text <- paste0(text, "\n\n")
      text <- paste0(text, private$getParametersText())
      text <- paste0(text, "\n")

      writeLines(text, con = paste0(private$mainPath, "/scripts/", private$algorithmName, "/", private$dataName, "/", "config0s0", ".txt"))

    },


    #Read algorithm output files
    readOutputs = function(trafile, tstfile, txtfile){

      #Check prediction files
      if((! file.exists(trafile)) || (! file.exists(tstfile))){
        cat(trafile, "\n", sep="")
        cat(tstfile, "\n", sep="")
        stop("Results were not stored. Execution error.")
      }

      #Read text output file only if it exists
      if(! file.exists(txtfile)) {
        self$output <- NULL
      }
      else {
        #Read output from txt file
        self$output <- readLines(txtfile, warn = FALSE)
      }

      #Read predictions
      self$trainPredictions <- private$readPredictionOutputs(trafile)
      self$testPredictions <- private$readPredictionOutputs(tstfile)
    },


    #Read prediction outputs
    readPredictionOutputs = function(file) {

      #Read file
      text <- readLines(file, warn = FALSE)

      #Find classes
      i <- 1
      while(!grepl("@data", tolower(text[i]))){
        i <- i+1
      }
      #Place i in class attribute line (last attribute)
        #before, I did only i<-i-1, but may be a empty line
      while(!grepl("@attribute", tolower(text[i]))){
        i <- i-1
      }
      #Obtain class names
      classes <- gdata::trim(strsplit(strsplit(strsplit(text[i], "{", fixed = TRUE)[[1]][2], "}", fixed=TRUE)[[1]][1], ",", fixed=TRUE)[[1]])

      while(text[i] != "@data"){
        i <- i+1
      }
      #now, text[i] is "@data"
      i <- i+1
      #now, text[i] is the firs preditcion

      real <- c()
      predictions <- c()

      for(j in i:length(text)){
        for(c in 1:length(classes)){
          if(strsplit(text[j], " ")[[1]][1] == classes[c]){
            real <- c(real, classes[c])
          }
          if(strsplit(text[j], " ")[[1]][2] == classes[c]){
            predictions <- c(predictions, classes[c])
          }
        }
      }

      m <- matrix(data = c(real, predictions), ncol=2)
      colnames(m) <- c("Real", "Predicted")

      dataframe <- data.frame(m, stringsAsFactors = FALSE)
      return(dataframe)
    }

  )
)
