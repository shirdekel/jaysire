
#' Specify a survey page with Likert scale items
#'
#' @description The \code{trial_survey_likert} function is used to display a
#' survey page with one or more items with Likert scale responses.
#'
#' @param questions A question or list of questions
#' @param preamble Text to appear above the questions
#' @param scale_width Width of the scale in pixels (NULL is the display width)
#' @param randomize_question_order Should order be randomised?
#' @param button_label Text for the continue button
#'
#' @param post_trial_gap  The gap in milliseconds between the current trial and the next trial. If NULL, there will be no gap.
#' @param on_finish A javascript callback function to execute when the trial finishes
#' @param on_load A javascript callback function to execute when the trial begins, before any loading has occurred
#' @param data An object containing additional data to store for the trial
#'
#'@return Functions with a \code{trial_} prefix always return a "trial" object.
#' A trial object is simply a list containing the input arguments, with
#' \code{NULL} elements removed. Logical values in the input (\code{TRUE} and
#' \code{FALSE}) are transformed to character vectors \code{"true"} and \code{"false"}
#' and are specified to be objects of class "json", ensuring that they will be
#' written to file as the javascript logicals, \code{true} and \code{false}.
#'
#'
#' @details The \code{trial_survey_likert} function creates a trial that displays
#' a set of questions with Likert scale responses.
#'
#' \subsection{Survey construction}{
#'
#' There are five arguments that are relevant to the survey itself:
#'
#' \itemize{
#' \item The main argument is \code{questions}, which can and can either consist of a single
#' question object generated b y\code{\link{question_likert}} or a list of such objects.
#' The Likert scale items are laid out on an ordered scale with radio buttons
#' spaced at equal intervals, whose labels are specified when calling
#' \code{\link{question_likert}}. See
#' the documentation for the question function for details of what this entails.
#'
#' \item The \code{preamble} argument is used to specify introductory text that appears
#' about the survey page. It accepts HTML markup and so can be used quite flexibly.
#'
#' \item The \code{scale_width} parameter controls the horizontal width of the Likert
#' scale, in pixels. By default, this is set to 100\% of the width of the jsPsych container
#' (which may not be 100\% of the screen width).
#'
#' \item The \code{randomize_question_order} argument is a logical value that
#' indicates whether or not the survey items should appear in a random order.
#'
#' \item The \code{button_label} specifies text to appear on the button displayed
#' at the bottom of the page, and which the participant must click before moving
#' on to the next trial.
#' }
#' }
#'
#' \subsection{Other behaviour}{
#'
#' Like all functions in the \code{trial_} family it contains four additional
#' arguments:
#'
#' \itemize{
#' \item The \code{post_trial_gap} argument is a numeric value specifying the
#' length of the pause between the current trial ending and the next one
#' beginning. This parameter overrides any default values defined using the
#' \code{\link{build_experiment}} function, and a blank screen is displayed
#' during this gap period.
#'
#' \item The \code{on_load} and \code{on_finish} arguments can be used to
#' specify javascript functions that will execute before the trial begins or
#' after it ends. The javascript code can be written manually and inserted *as*
#' javascript by using the \code{\link{insert_javascript}} function. However,
#' the \code{fn_} family of functions supplies a variety of functions that may
#' be useful in many cases.
#'
#' \item The \code{data} argument can be used to insert custom data values into
#' the jsPsych data storage for this trial
#' }
#' }
#'
#' \subsection{Data}{
#'
#' When this function is called from R it returns the trial object that will
#' later be inserted into the experiment when \code{\link{build_experiment}}
#' is called. However, when the trial runs as part of the experiment it returns
#' values that are recorded in the jsPsych data store and eventually form part
#' of the data set for the experiment.
#'
#'
#' The data recorded by this trial is as follows:
#'
#' \itemize{
#' \item The \code{responses} value is a
#' an array containing all selected choices in JSON format for each question. The
#' encoded object will have a separate variable for the response to each question,
#' with the first question in the trial being recorded in Q0, the second in Q1, and
#' so on. The responses are recorded as the name of the option label. If the
#' \code{name} parameter is defined for the question, then the response will use
#' the value of \code{name} as the key for the response in the responses object.
#'
#' \item The \code{rt} value is the response time in milliseconds for the subject to make
#' a response. The time is measured from when the questions first appear on the
#' screen until the subject's response.
#'
#' \item The \code{question_order} value is a string in JSON format containing an array
#' with the order of questions. For example [2,0,1] would indicate that the first
#' question was trial.questions[2] (the third item in the questions parameter), the
#' second question was trial.questions[0], and the final question was trial.questions[1].
#' }
#'
#' In addition, it records default variables that are recorded by all trials:
#'
#' \itemize{
#' \item \code{trial_type} is a string that records the name of the plugin used to run the trial.
#' \item \code{trial_index} is a number that records the index of the current trial across the whole experiment.
#' \item \code{time_elapsed} counts the number of milliseconds since the start of the experiment when the trial ended.
#' \item \code{internal_node_id} is a string identifier for the current "node" in the timeline.
#' }
#' }
#'
#' @seealso Survey page trials are constructed using the \code{\link{trial_survey_text}},
#' \code{\link{trial_survey_likert}}, \code{\link{trial_survey_multi_choice}} and
#' \code{\link{trial_survey_multi_select}} functions. Individual questions for survey
#' trials can be specified using \code{\link{question_text}},
#' \code{\link{question_likert}} and \code{\link{question_multi}}.
#'
#' @export
trial_survey_likert <- function(
  questions,
  preamble = "",
  scale_width = NULL,
  randomize_question_order = FALSE,
  button_label = "Continue",

  post_trial_gap = 0,  # start universals
  on_finish = NULL,
  on_load = NULL,
  data = NULL
) {

  # if the user has passed a single question, wrap it in a list
  if(class(questions) == "jspr_likert") {
    questions <- list(questions)
  }

  # [add check to ensure questions are the correct type]

  # questions need to be tidied before passing to jsPsych
  questions <- purrr::map(questions, function(q) {
    unclass(drop_nulls(q))
  })

  # return object
  drop_nulls(
    trial(
      type = "survey-likert",
      questions = list_to_jsarray(questions),
      randomize_question_order = js_logical(randomize_question_order),
      preamble = as.character(preamble),
      scale_width = scale_width,
      button_label = as.character(button_label),

      post_trial_gap = post_trial_gap,
      on_finish = on_finish,
      on_load = on_load,
      data = data
    )
  )
}


#' Create a Likert question
#'
#' @param prompt the prompt for the question
#' @param labels the labels on the Likert scale
#' @param required is a response to the question required?
#' @param name a convenient label for the question
#'
#' @return A question object to be passed to \code{\link{trial_survey_likert}()}.
#'
#' @details The \code{question_likert()} function is designed to be called when
#' using \code{\link{trial_survey_likert}()} to construct a survey page that contains
#' Likert scale response items. When rendered as part of the study, the text specified
#' by the \code{prompt} argument is shown to the participant, with a set of ordered
#' categories displayed along a horizontal line. The \code{labels} for these categories
#' are shown beneath the line, and the participant responds by selecting a radio button
#' that is placed along the line. If \code{required = TRUE} the participant will not
#' be allowed to continue to the next trial unless an answer is provided.
#'
#' The \code{name} argument should be a string that provides a convenient
#' label for the question. If left unspecified, jsPsych defaults to labelling
#' the questions within a survey page as "Q0", "Q1", "Q2", etc.
#'
#' @seealso Survey page trials are constructed using the \code{\link{trial_survey_text}},
#' \code{\link{trial_survey_likert}}, \code{\link{trial_survey_multi_choice}} and
#' \code{\link{trial_survey_multi_select}} functions. Individual questions for survey
#' trials can be specified using \code{\link{question_text}},
#' \code{\link{question_likert}} and \code{\link{question_multi}}.
#'
#' @export
question_likert <- function(
  prompt,
  labels,
  required = FALSE,
  name = NULL
) {
  q <- drop_nulls(
    list(
      prompt = prompt,
      labels = labels,
      required = required,
      name = name
    )
  )
  return(structure(q, class = "jspr_likert"))
}
