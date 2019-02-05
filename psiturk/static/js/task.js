/*
 * Requires:
 *     psiturk.js
 *     utils.js
 */

// Initalize psiturk object
var psiTurk = new PsiTurk(uniqueId, adServerLoc, mode);

// Objects to keep track of the current phase and state
var CURRENTVIEW;
var STATE;

var MOVIESCREEN = "moviescreen";
var SLIDER = "slider";
var NEXTBUTTON = "nextbutton";
var PROGRESS = "progress";
var RELOAD = "reloadbutton";

var INS_INSTRUCTS = "instruct";
var INS_SLIDER = "slider_div";
var INS_NEXTBUTTON = "nextbutton";
var INS_NEXTCLICK = "notnext";
var INS_HEADER = "instr_header";

var IMG_TIME = 100 // time to display images in ms

// All pages to be loaded
var pages = [
  "instructions/instructions.html",
  "instructions/instruct-1.html",
  "quiz.html",
  "restart.html",
  "stage.html",
  "postquestionnaire.html"
];

psiTurk.preloadPages(pages);


var instructionPages = [ // add as a list as many pages as you like
  "instructions/instruct-1.html"
];

function pickTrickSpots(numStim, numTricks) {
  var nums =  [...Array(numStim).keys()];
  // We don't want any tricks in the first 4 videos
  for (var i = 0; i < 4; i++) {
    nums.splice(0, 1)
  }
  var spots = new Array(numTricks);
  for (var i = 0; i < numTricks; i++) {
    var ind = Math.floor(Math.random() * nums.length);
    spots[i] = nums[ind];
    if (ind+1 < nums.length) {
      nums.splice(ind+1,1);
    }
    nums.splice(ind,1);
    nums.splice(ind-1,1);
  }
  return spots;
}

function shuffle(array) {
  var currentIndex = array.length,
    temporaryValue, randomIndex;

  // While there remain elements to shuffle...
  while (0 !== currentIndex) {

    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }

  return array;
};

// Note data should just be what is read in from condlist.json
function orderStimuli(data) {
  var standard = shuffle(data[0])
  var pickTrickObjects = [-1,-1,-1,-1,-1,-1];
  for (var i = 0; i < 6; i++) {
    var ind = Math.floor(Math.random() * 3);
    pickTrickObjects[i] = data[1][i*3+ind];
  }
  var tricks = shuffle(pickTrickObjects);
  var trickSpots = pickTrickSpots(standard.length+tricks.length, tricks.length);
  var standardCounter = 0;
  var trickCounter = 0;
  var retval = new Array(standard.length+tricks.length);
  for (var i = 0; i < standard.length+tricks.length; i++) {
    if (trickSpots.includes(i)) {
      retval[i] = tricks[trickCounter];
      trickCounter++;
    }
    else {
      retval[i] = standard[standardCounter];
      standardCounter++;
    }
  }
  return retval;
}


var black_div = function() {
  return '<div style=\"background-color: black; width: 80vmin; height: 45vmin;\"></div>'
}

var cut2black = function() {
  setTimeout(
    function() {
      var sc = document.getElementById(MOVIESCREEN)
      sc.innerHTML = black_div()
    }, IMG_TIME
  )

}

var make_img = function(imgname, is_intro, freeze) {
  if (typeof(is_intro) === 'undefined') is_intro = false;
  if (typeof(freeze) === 'undefined') freeze = true
  var mcl = "movieobj"
  if (is_intro) {
    mcl = "movieobj_sm"
  }
  var r =  "<image id=\"thisimg\" "
  if (freeze) {
    r += "onload=\"cut2black()\" "
  }
  r += "class=\"" + mcl + "\" src=\"static/movie/" + imgname + "\" alt=\"Movie\">"
  return r
  //return "<image id=\"thisimg\" onload=\"cut2black()\" class=\"" + mcl + "\" src=\"static/movie/" + imgname + "\" alt=\"Movie\">";
};

var make_mov = function(movname, is_intro, has_ctr) {
  if (typeof(is_intro) === 'undefined') is_intro = false;
  if (typeof(has_ctr) === 'undefined') has_ctr = true;
  var mcl = "movieobj";
  var ctr = "";
  var fmovnm = "static/movie/BounceHidden/" + movname; // BounceShown or BounceHidden depending on experiment
  var foggnm = fmovnm.substr(0, fmovnm.lastIndexOf('.')) + ".ogg";
  var ret = "<video id=\"thisvideo\" class=\"" + mcl + "\"" + ctr + "><source src=\"" + fmovnm;
  ret += "\" type=\"video/mp4\"><source src=\"" + foggnm + "\" type=\"video/ogg\">";
  ret += "Your browser does not support HTML5 mp4 video.</video>";
  return ret;
};

/********************
 * HTML manipulation
 *
 * All HTML files in the templates directory are requested
 * from the server when the PsiTurk object is created above. We
 * need code to get those pages from the PsiTurk object and
 * insert them into the document.
 *
 ********************/



var Experiment = function(triallist) {
  psiTurk.finishInstructions();
  psiTurk.showPage('stage.html');
  var triallist = triallist; // shuffle(triallist);
  var screen = document.getElementById(MOVIESCREEN);
  var slider = document.getElementById(SLIDER);
  var button = document.getElementById(NEXTBUTTON);
  var prog = document.getElementById(PROGRESS);
  var reloadbtn = document.getElementById(RELOAD);
  var curidx = 0;
  var starttime = -1;

  var start_experiment = function() {
    curidx = 0;
    run_trial();
  };

  var run_trial = function() {
    var curtrial = triallist[curidx];
    show_progress();
    var flnm = curtrial[0];
    var trtype = curtrial[1];
    disable_slider();
    button.disabled = true;
    if (trtype === 'image') {
      screen.innerHTML = make_img(flnm);
      enable_slider();
    } else {
      var tmo = setTimeout(function() {
        reloadbtn.style.display = "";
      }, 2000);
      screen.innerHTML = make_mov(flnm);
      slider.disabled = true;
      var vid = document.getElementById('thisvideo');
      vid.onended = function() {
        enable_slider()// After 100ms, fade to black
        /*
        setTimeout(function() {
          screen.innerHTML = black_div()
        }, IMG_TIME)
        */
      };
      vid.oncanplay = function() {
        clearTimeout(tmo);
        reloadbtn.style.display = "none";
        /*
        vid.addEventListener('ended', myHandler, false);

        function myHandler(e) {
          //console.log('ended');
          setTimeout(function() {
            vid.play();
          }, 2000);
        }
        */

        vid.play();
      };
    }
    starttime = new Date().getTime();
  };

  var reload_movie = function() {
    var curtrial = triallist[curidx];
    var flnm = curtrial[0];
    var trtype = curtrial[1];
    if (trtype !== "movie") {
      console.log("ERROR! Cannot reload if stimulus is not a movie");
    } else {
      screen.innerHTML = make_mov(flnm);
      slider.disabled = true;
      var vid = document.getElementById('thisvideo');
      vid.onended = function() {
        enable_slider()
      };
      vid.oncanplay = function() {
        reloadbtn.style.display = "none";
        vid.play();
      };
    }
  };

  var register_response = function() {
    var rt = new Date().getTime() - starttime;
    var ch = slider.value;
    // Records as [trialname, choice of mass, reaction time]
    psiTurk.recordTrialData({
      'TrialName': triallist[curidx][0],
      'Rating': ch,
      'ReactionTime': rt,
      'IsInstruction': false,
      'TrialOrder': curidx
    });
    next_trial();
  };

  var next_trial = function() {
    curidx += 1;
    if (curidx === triallist.length) {
      end();
    } else {
      run_trial();
    }
  };

  var end = function() {
    psiTurk.saveData();
    new Questionnaire();
  };

  var show_progress = function() {
    prog.innerHTML = (curidx + 1) + " / " + (triallist.length);
  };

  var enable_button = function() {
    slider.className = '';
    button.disabled = false;
  };

  var disable_slider = function() {
    slider.value = 50;
    slider.disabled = true;
    slider.className = "drange";
  };

  var enable_slider = function() {
    slider.className = "drange";
    slider.disabled = false;
  };

  button.disabled = true;
  button.onclick = function() {
    register_response();
  };
  slider.onmousedown = function() {
    enable_button()
  };
  reloadbtn.onclick = function() {
    reload_movie();
  };

  start_experiment();
};



/****************
 * Instructions  *
 ****************/

var loop = 1;
var quiz = function(complete_fn, condlist) {
  function record_responses() {
    var allRight = true;
    $('select').each(function(i, val) {
      psiTurk.recordTrialData({
        'phase': "INSTRUCTQUIZ",
        'question': this.id,
        'answer': this.value
      });
      if (this.id === 'featureAttend' && this.value != 'loudness') {
        allRight = false;
      } else if (this.id === 'constantObj' && this.value != 'wood') {
        allRight = false;
      } else if (this.id === 'densOrder' && this.value != 'second') {
        allRight = false;
      } else if (this.id === 'endSign' && this.value != 'third') {
        allRight = false;
      }
    });
    return allRight
  };

  psiTurk.showPage('quiz.html')
  $('#continue').click(function() {
    if (record_responses()) {
      // Record that the user has finished the instructions and
      // moved on to the experiment. This changes their status code
      // in the database.
      psiTurk.recordUnstructuredData('instructionloops', loop);
      psiTurk.finishInstructions();
      // Move on to the experiment
      complete_fn();
    } else {
      loop++;
      psiTurk.showPage('restart.html');
      $('.continue').click(function() {
        psiTurk.doInstructions(
          instructionPages,
          function() {
            InstructionRunner(condlist)
          });
      });
    }
  });
};

var InstructionRunner = function(condlist) {
  psiTurk.showPage('instructions/instructions.html');

  var instruct = document.getElementById(INS_INSTRUCTS);
  var slider = document.getElementById(INS_SLIDER);
  var next = document.getElementById(INS_NEXTBUTTON);
  var clnext = document.getElementById(INS_NEXTCLICK);
  var mvsc = document.getElementById(MOVIESCREEN);
  var reloadbtn = document.getElementById(RELOAD);
  var nTrials = condlist.length;

  clnext.onclick = function() {
    do_next();
  };

  // Series of Instructions: [text, stimulus, stim type, use slider]
  var lists = [


    ["In this task, you will observe a wooden object (the <b>falling object</b>) fall vertically " +
      "onto a surface (the <b>ground surface</b>).<br></br>" +
      "Your job is to give a loudness judgement on the sound made when the falling object collides with the ground surface.",
      "setup2.png", "image", "skip"
    ],

    ["The falling object will always be wood. The shape will be a: <b>cube, cylinder,</b> or <b>sphere</b> as shown below.</br></br>" +
      "The falling objects all have similar masses and physical properties.</br></br>",
      "labeled_objects.png", "image", "skip"
    ],

    ["The ground surface can be made of three materials: <b>foam, ceramic,</b> or <b>wood</b> as shown below.</br></br>" +
      "A material's appearance corresponds to its physical properties.</br></br>" +
      "For example, foam is softer than wood, which is softer than ceramic. Harder surfaces tend to make louder sounds.",
      "labeled_surfaces2.png", "image", "skip"
    ],


    ["In the movie that will play when you click 'next,' a wooden <b>sphere</b> starts above a ceramic plate (<b>ground surface</b>) and" +
      " falls down. On impact with the ceramic, it makes a sound. " +
      "As you can hear, the sound is loud due to the <b>ceramic</b> plate. </br></br> Note you will not be able to replay the short scene, so play close attention!",
      "none", "none", "skip"
    ],

    ["In the movie that will play when you click 'next,' a wooden <b>cube</b> starts above a ceramic plate (<b>ground surface</b>) and" +
      " falls down. On impact with the ceramic, it makes a sound. " +
      "As you can hear, the sound is loud due to the <b>ceramic</b> plate.  </br></br> Note you will not be able to replay the short scene, so play close attention!",
      "MaskCubeOnPlate6DubbedPlate0.mp4", "movie", "skip"
    ],

    ["In the movie that will play when you click 'next,' the lights go out before the wooden cube drops. You will still hear the remainder of the audio." +
      "</br></br> In the experiment, the lights will <b>always go out</b> before the falling object starts to fall. The loudness judgement you make should be of the impact sound, which will be heard after the lights go out.",
      "none", "none", "skip"
    ],

    ["In the movie that will play when you click 'next,' the lights go out before the wooden cube drops. You will still hear the remainder of the audio." +
      "</br></br> In the experiment, the lights will <b>always go out</b> before the falling object starts to fall. The loudness judgement you make should be of the impact sound, which will be heard after the lights go out.",
      "HiddenCubeOnPlate6DubbedPlate0.mp4", "movie", "skip"
    ],


    ["Remember that <b>the material of the ground surface dictates the loudness of impact sound.</b></br></br> As a reminder, the material of <b>the falling object is always wood</b>, but the material of <b>the ground surface will vary</b> between trials (either foam, ceramic, or wood).",
      "none", "none", "skip"
    ],

  ["Here's another example of a wooden sphere falling on foam. As expected, this sound is softer than the earlier ceramic one. Click 'next' to see the video.",
      "none", "none", "skip"
    ],

    ["Here's another example of a wooden sphere falling on foam. As expected, this sound is softer than the earlier ceramic one. Click 'next' to proceed.",
      "HiddenSphereOnFoam6DubbedFoam0.mp4", "movie", "skip"
    ],

    ["To register your decision you will see a slider like the one below that will ask you to indicate your loudness judgement.</br></br>" +
      "<b>You must move the slider before you can progress in the experiment,</b> but you also cannot move the slider until the video ends.<br> Please try this out before continuing.",
      "none", "none", "use"
    ],

    ["After a short check to ensure that you have understood the instructions and a practice scene, " +
      "you will record your judgments about " + nTrials + " scenes.<br>",
      "none", "none", "skip"
    ],

  ];
  var ninstruct = lists.length;
  var instruct_idx = 0;

  var do_next = function() {


    if (instruct_idx === ninstruct) {
      end();
    } else {
      var i = lists[instruct_idx];

      var usemov;
      // Input types
      if (i[2] === 'movie') {
        mvsc.innerHTML = make_mov(i[1], true);
        usemov = true;
      } else if (i[2] === 'image') {
        // clnext.disabled = true;
        mvsc.innerHTML = make_img(i[1], true, false) + "<br>";
        usemov = false;
      } else {
        mvsc.innerHTML = "";
        usemov = false;
      }
      instruct.innerHTML = i[0];


      // Deal with the slider - either show it or register it
      if (i[3] === 'show' | i[3] === "use") {
        slider.innerHTML = "<span id=\"qspan\">How loud was the sound?</span>" +
          "<div id=\"lab-div\"><div id=\"lab-left\"><i>Very soft</i></div>" +
          "<div id=\"lab-center\"><i>Medium</i></div><div id=\"lab-right\"><i>Very loud</i></div></div>" +
          "<input id=\"ins_slider\" type=\"range\" min=\"0\" max=\"100\" default=\"50\" width=\"1500\"/>";
      } else {
        slider.innerHTML = "";
      }



      if (usemov) {
        reloadbtn.onclick = function() {
          reload_movie(me, i[1]);
        };
        var tmo = setTimeout(function() {
          reloadbtn.style.display = "";
        }, 2000);
        clnext.disabled = true;
        var mov = document.getElementById('thisvideo');

        mov.oncanplay = function() {
          clearTimeout(tmo);
          reloadbtn.style.display = "none";
          /*
          mov.addEventListener('ended', myHandler, false);

          function myHandler(e) {
            //console.log('ended');
            setTimeout(function() {
              mov.play();
            }, 2000);
          }
          */

          mov.play();
        };

        if (i[3] === "use") {
          var sl = document.getElementById('ins_slider');
          sl.disabled = true;
          mov.onended = function() {
            sl.disabled = false;
          };
          sl.onclick = function() {
            clnext.disabled = false;
          };
        } else {
          mov.onended = function() {
            clnext.disabled = false;
          };
        }

      } else {
        if (i[3] === "use") {
          clnext.disabled = true;
          var sl = document.getElementById('ins_slider');
          sl.onclick = function() {
            clnext.disabled = false;
          };
        } else {
          clnext.disabled = false;
        }
      }

      instruct_idx += 1;
    }



  };

  var end = function() {
    next.innerHTML = "<center><button type=\"button\" id=\"next\" value=\"next\" class=\"btn btn-success btn-lg continue\">Begin Experiment <span class=\"glyphicon glyphicon-arrow-right\"></span></button></center>";
    quiz(function() {
      currentview = new PracticeTrials(condlist)
    }, condlist);
  };
  do_next();
};

var PracticeTrials = function(condlist) {
  psiTurk.showPage('instructions/instructions.html');

  var hdr = document.getElementById(INS_HEADER);
  var instruct = document.getElementById(INS_INSTRUCTS);
  var slider = document.getElementById(INS_SLIDER);
  var next = document.getElementById(INS_NEXTBUTTON);
  var clnext = document.getElementById(INS_NEXTCLICK);
  var mvsc = document.getElementById(MOVIESCREEN);
  var reloadbtn = document.getElementById(RELOAD);
  var nTrials = typeof(numTrials) === 'undefined' ? 0 : condlist.length;


  clnext.onclick = function() {
    do_next();
  };

  hdr.innerHTML = "Practice trial";

  // Series of Instructions: [text, stimulus, stim type, use slider]
  var lists = [

    ["Good job on completing the quiz!<br>To get you familiar with the experiment, you will first see another practice scene.</br></br>" +
      "<b>Remember: you must move the slider before you can progress</b>.", "none", "none", "skip"
    ],

    ["Practice Scene 1/1",
      "HiddenCylOnWood8DubbedWood0.mp4", "movie", "record"
    ],

    ["You are now ready to start the experiment.<br> Press next when ready.",
      "none", "none", "skip"
    ],

  ];
  var ninstruct = lists.length;
  var instruct_idx = 0;

  var do_next = function() {
    if (instruct_idx === ninstruct) {
      end();
    } else {
      if (instruct_idx === ninstruct-1) {
        hdr.innerHTML = "Practice trial over!";
      }
      var i = lists[instruct_idx];
      var inpt, usemov;
      // Input types
      if (i[2] === 'movie') {
        instruct.hidden = true
        mvsc.innerHTML = make_mov(i[1], true);
        usemov = true;
      } else if (i[2] === 'image') {
        instruct.hidden = true
        // clnext.disabled = true;
        mvsc.innerHTML = make_img(i[1], true, true) + "<br>";
        // After 100ms, fade to black
        setTimeout(function() {
          mvsc.innerHTML = black_div()
        }, IMG_TIME)
        usemov = false;
      } else {
        instruct.hidden = false
        mvsc.innerHTML = "";
        usemov = false;
      }
      instruct.innerHTML = i[0];


      // Deal with the slider - either show it or register it
      if (i[3] === 'show' | i[3] === "use" | i[3] === "record") {
        slider.innerHTML = "<span id=\"qspan\">How loud was the sound?</span>" +
          "<div id=\"lab-div\"><div id=\"lab-left\"><i>Very soft</i></div>" +
          "<div id=\"lab-center\"><i>Medium</i></div><div id=\"lab-right\"><i>Very loud</i></div></div>" +
          "<input id=\"ins_slider\" type=\"range\" min=\"0\" max=\"100\" default=\"50\" width=\"1500\"/>";
      } else {
        slider.innerHTML = "";
      }



      if (usemov) {
        reloadbtn.onclick = function() {
          reload_movie(me, i[1]);
        };
        var tmo = setTimeout(function() {
          reloadbtn.style.display = "";
        }, 2000);
        clnext.disabled = true;
        var mov = document.getElementById('thisvideo');

        mov.oncanplay = function() {
          clearTimeout(tmo);
          reloadbtn.style.display = "none";
          /*
          mov.addEventListener('ended', myHandler, false);

          function myHandler(e) {
            //console.log('ended');
            setTimeout(function() {
              mov.play();
            }, 2000);
          }
          */

          mov.play();
        };

        if (i[3] === "use" | i[3] === "record") {
          var sl = document.getElementById('ins_slider');
          sl.disabled = true;
          mov.onended = function() {
            sl.disabled = false;
          };
          sl.onclick = function() {
            register_response();
          };
        } else {
          mov.onended = function() {
            clnext.disabled = false;
          };
        }

      } else {
        if (i[3] === "use" | i[3] === "record") {
          clnext.disabled = true;
          var sl = document.getElementById('ins_slider');
          sl.onclick = function() {
            register_response();
          };
        } else {
          clnext.disabled = false;
        }
      }

      instruct_idx += 1;

    }



  };

  var register_response = function() {
    clnext.disabled = false;
    var sl = document.getElementById('ins_slider');
    var ch = sl.value;
    // Records as [trialname, choice of mass, reaction time]
    psiTurk.recordTrialData({
      'TrialName': instruct_idx,
      'Rating': ch,
      'ReactionTime': 0,
      'IsInstruction': true,
      'TrialOrder': instruct_idx
    });
  };

  var end = function() {

    hdr.innerHTML = "Instructions"
    next.innerHTML = "<center><button type=\"button\" id=\"next\" value=\"next\" class=\"btn btn-success btn-lg continue\">Begin Experiment <span class=\"glyphicon glyphicon-arrow-right\"></span></button></center>";
    currentview = new Experiment(condlist);
    // quiz(function(){currentview = new Experiment(condlist)});
  };
  do_next();

};


/****************
 * Questionnaire *
 ****************/

var Questionnaire = function() {

  var error_message = "<h1>Oops!</h1><p>Something went wrong submitting your HIT. This might happen if you lose your internet connection. Press the button to resubmit.</p><button id='resubmit'>Resubmit</button>";

  record_responses = function() {

    psiTurk.recordTrialData({
      'phase': 'postquestionnaire',
      'status': 'submit'
    });

    $('textarea').each(function(i, val) {
      psiTurk.recordUnstructuredData(this.id, this.value);
    });
    $('select').each(function(i, val) {
      psiTurk.recordUnstructuredData(this.id, this.value);
    });

  };

  prompt_resubmit = function() {
    document.body.innerHTML = error_message;
    $("#resubmit").click(resubmit);
  };

  resubmit = function() {
    document.body.innerHTML = "<h1>Trying to resubmit...</h1>";
    reprompt = setTimeout(prompt_resubmit, 10000);

    psiTurk.saveData({
      success: function() {
        clearInterval(reprompt);
        psiTurk.computeBonus('compute_bonus', function() {
          finish()
        });
      },
      error: prompt_resubmit
    });
  };

  // Load the questionnaire snippet
  psiTurk.showPage('postquestionnaire.html');
  psiTurk.recordTrialData({
    'phase': 'postquestionnaire',
    'status': 'begin'
  });

  $("#next").click(function() {
    record_responses();
    psiTurk.saveData({
      success: function() {
        psiTurk.completeHIT(); // when finished saving compute bonus, the quit
      },
      error: prompt_resubmit
    });
  });


};

// Task object to keep track of the current phase
var currentview;

/*******************
 * Run Task
 ******************/

$(window).load(function() {

  // Load in the conditions
  // TEMPORARY

  function do_load() {
    $.ajax({
      dataType: 'json',
      url: "static/json/condlist.json",
      async: false,
      success: function(data) {
        condlist = orderStimuli(data)
        InstructionRunner(condlist)
        /*
        psiTurk.doInstructions(
            instructionPages, // a list of pages you want to display in sequence
            function() { InstructionRunner(condlist) } // what you want to do when you are done with instructions
        );
        */
        // exp = new Experiment(psiTurk, condlist);
      },
      error: function() {
        setTimeout(500, do_load)
      },
      failure: function() {
        setTimeout(500, do_load)
      }
    });
  };

  do_load();

});
