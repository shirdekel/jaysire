/**
 * jspsych-survey-html-form4
 * a jspsych plugin for free html forms
 * for Shir's managers study
 * 
 * Jan Simson
 *
 * documentation: docs.jspsych.org
 *
 */

jsPsych.plugins['survey-html-form4'] = (function() {

  var plugin = {};

  plugin.info = {
    name: 'survey-html-form4',
    description: '',
    parameters: {
      html: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name: 'HTML',
        default: null,
        description: 'HTML formatted string containing all the input elements to display. Every element has to have its own distinctive name attribute. The <form> tag must not be included and is generated by the plugin.'
      },
      preamble: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Preamble',
        default: null,
        description: 'HTML formatted string to display at the top of the page above all the questions.'
      },
      button_label: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Button label',
        default:  'Continue',
        description: 'The text that appears on the button to finish the trial.'
      },
      dataAsArray: {
        type: jsPsych.plugins.parameterType.BOOLEAN,
        pretty_name: 'Data As Array',
        default:  false,
        description: 'Retrieve the data as an array e.g. [{name: "INPUT_NAME", value: "INPUT_VALUE"}, ...] instead of an object e.g. {INPUT_NAME: INPUT_VALUE, ...}.'
      }
    }
  }

  plugin.trial = function(display_element, trial) {
    
    var html = '';
    // show preamble text
    if(trial.preamble !== null){
      html += '<div id="jspsych-survey-html-form4-preamble" class="jspsych-survey-html-form4-preamble">'+trial.preamble+'</div>';
    }
    // start form
    html += '<form id="jspsych-survey-html-form4">'

    // add form HTML / input elements
    html += trial.html;

    // add submit button
    html += '<p><input type="submit" id="jspsych-survey-html-form4-next" class="jspsych-btn jspsych-survey-html-form4" value="'+trial.button_label+'"></input></p>';

    html += '</form>'
    display_element.innerHTML = html;

    display_element.querySelector('#jspsych-survey-html-form4').addEventListener('submit', function(event) {
      // don't submit form
      event.preventDefault();
      
    // FORM VALIDATION EDIT
    var allocation_vals = display_element.querySelector('#jspsych-survey-html-form4').querySelectorAll('[name*="allocation"]');
    var sum = 0;
    for (var m = 0; m < allocation_vals.length; m++) {
      sum = sum + Number(allocation_vals[m].value); // calculate sum of array values
    }
    
    var ranking_vals = display_element.querySelector('#jspsych-survey-html-form4').querySelectorAll('[name*="ranking"]');
    var rank = [];
      for (var k = 0; k < ranking_vals.length; k++) {
        rank.push(Number(ranking_vals[k].value));
      }
      
        // from https://stackoverflow.com/a/7376645/13945974
        function hasDuplicates(array) {
            var valuesSoFar = Object.create(null);
            for (var i = 0; i < array.length; ++i) {
                var value = array[i];
                if (value in valuesSoFar) {
                    return true;
                }
                valuesSoFar[value] = true;
            }
            return false;
        }

        var rank_duplicated = hasDuplicates(rank);

        var urlvar = jsPsych.data.urlVariables();

        var test = false;

        if (typeof urlvar.test !== 'undefined') {
            test = urlvar.test;
        }

        if (sum !== 100 && !test) {
            var msg = "Total budget allocation must sum to 100. Currently, the sum is " + sum + ".";
            alert(msg);
        } else if (rank_duplicated && !test) {
        alert("Each project's rank must be unique. Currently, one or more ranks are repeated.");
      } else { // resume normal functioning
        // measure response time
        var endTime = performance.now
        var response_time = endTime - startTime;
  
        var question_data = serializeArray(this);
  
        if (!trial.dataAsArray) {
          question_data = objectifyForm(question_data);
        }
  
        // save data
        var trialdata = {
          "rt": response_time,
          "responses": JSON.stringify(question_data)
        };
  
        display_element.innerHTML = '';
  
        // next trial
        jsPsych.finishTrial(trialdata);
      }
      
    });

    var startTime = performance.now();
  };

  /*!
   * Serialize all form data into an array
   * (c) 2018 Chris Ferdinandi, MIT License, https://gomakethings.com
   * @param  {Node}   form The form to serialize
   * @return {String}      The serialized form data
   */
  var serializeArray = function (form) {
    // Setup our serialized data
    var serialized = [];

    // Loop through each field in the form
    for (var i = 0; i < form.elements.length; i++) {
      var field = form.elements[i];

      // Don't serialize fields without a name, submits, buttons, file and reset inputs, and disabled fields
      if (!field.name || field.disabled || field.type === 'file' || field.type === 'reset' || field.type === 'submit' || field.type === 'button') continue;

      // If a multi-select, get all selections
      if (field.type === 'select-multiple') {
        for (var n = 0; n < field.options.length; n++) {
          if (!field.options[n].selected) continue;
          serialized.push({
            name: field.name,
            value: field.options[n].value
          });
        }
      }

      // Convert field data to a query string
      else if ((field.type !== 'checkbox' && field.type !== 'radio') || field.checked) {
        serialized.push({
          name: field.name,
          value: field.value
        });
      }
    }

    return serialized;
  };

  // from https://stackoverflow.com/questions/1184624/convert-form-data-to-javascript-object-with-jquery
  function objectifyForm(formArray) {//serialize data function
    var returnArray = {};
    for (var i = 0; i < formArray.length; i++){
      returnArray[formArray[i]['name']] = formArray[i]['value'];
    }
    return returnArray;
  }

  return plugin;
})();
