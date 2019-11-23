/* Disable inputs and add grey background on them*/
function disable_fields(elementId){

    var element = jq("#"+elementId);
    element.find("input").attr("disabled", true);
    element.find('select').attr("disabled", true);

    /* fade out the fields that are disabled */
    element.addClass("html-form-entry-disabled-field");
}

/* Enable inputs and remove grey background from them*/
function enable_fields(elementId){

    var element = jq("#"+elementId);
    element.find("input").attr("disabled", false);
    element.find('select').attr("disabled", false);
    element.removeClass("html-form-entry-disabled-field");
}

/* Determine MUAC color code from muac score and age */
function getMUACCodeFromMUACScoreByAge(age, muacScoreFieldId, muacCodeFieldId) {

    jq("#"+muacScoreFieldId).find("input[type$='text']").change(function() {

        var muacScore = jq(this).val().trim();

        if( muacScore == " " || muacScore == 0) {
            jq("#" + muacCodeFieldId).find("select").val(" ").attr("selected", "selected")
            return false;
        }

        if(age < 5) {

            if(muacScore < 11.5) {
                jq("#" + muacCodeFieldId).find("select").val(99028).attr("selected", "selected")
            }

            if(muacScore >= 11.5 && muacScore < 12.5) {
                jq("#" + muacCodeFieldId).find("select").val(99029).attr("selected", "selected")
            }

            if(muacScore >=12.5) {
                jq("#" + muacCodeFieldId).find("select").val(99027).attr("selected", "selected")
            }
        }

        if(age >= 5 && age < 10) {

            if(muacScore < 13.5) {
                jq("#" + muacCodeFieldId).find("select").val(99028).attr("selected", "selected")
            }

            if(muacScore >=13.5 && muacScore < 14.5) {
                jq("#" + muacCodeFieldId).find("select").val(99029).attr("selected", "selected")
            }

            if(muacScore >=14.5) {
                jq("#" + muacCodeFieldId).find("select").val(99027).attr("selected", "selected")
            }

        }

        if(age >=10 && age < 18) {

            if(muacScore < 16.5) {
                jq("#" + muacCodeFieldId).find("select").val(99028).attr("selected", "selected")
            }

            if(muacScore >=16.5 && muacScore < 19) {
                jq("#" + muacCodeFieldId).find("select").val(99029).attr("selected", "selected")
            }

            if(muacScore >=19) {
                jq("#" + muacCodeFieldId).find("select").val(99027).attr("selected", "selected")
            }

        }

        if(age >=18) {

            if(muacScore < 19) {
                jq("#" + muacCodeFieldId).find("select").val(99028).attr("selected", "selected")
            }

            if(muacScore >=19 && muacScore < 22) {
                jq("#" + muacCodeFieldId).find("select").val(99029).attr("selected", "selected")
            }

            if(muacScore >=22) {
                jq("#" + muacCodeFieldId).find("select").val(99027).attr("selected", "selected")
            }
        }
    });
}

/* Get period between two dates */
function periodBetweenDates(firstDate, secondDate) {
    var period = (secondDate.getTime() - firstDate.getTime()) / 1000;
    diff /= (60 * 60 * 24 * 7 * 4);
    return Math.abs(Math.round(period));
}