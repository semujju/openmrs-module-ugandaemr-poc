function enable_disable(field, class_name_prefix, conditions, input_type) {

            var class_name = jq(field).attr("class");

            var length = class_name.length;

            var class_id = parseInt(class_name.substring(length - 1, length));
            var childClass = "Child" + class_id;

            var disable = true;
            var requires = true;

            var row = '[class^="' + class_name_prefix + '"][class*="' + childClass + '"]';

            var selected_value = null;

            if (input_type == "select") {
                selected_value = jq(field).find(":selected").text().trim().toLowerCase();
            } else if (input_type == "hidden") {
                selected_value = jq(field).find("input[type=hidden]").val().trim().toLowerCase();
            }


            if (eval(conditions)) {
                disable = false;
            }


            jq(row).each(function () {
                var group = jq(this);

                if (class_name.indexOf('Child') == -1) {
                    /*group.find("input").attr("value", ""); */
                    group.find("input").attr("required", requires);
                    /* group.find('select').prop("selectedIndex", 0);*/
                    group.find("input").attr("disabled", disable);
                    group.find('select').attr("disabled", disable);

                    if (disable) {
                        /* fade out the fields that are disabled */
                        group.find("input").fadeTo(250, 0.25);
                        group.find("select").fadeTo(250, 0.25);
                    } else {
                        /* remove the fade on the fields */
                        group.find("input").fadeTo(250, 1);
                        group.find("select").fadeTo(250, 1);
                    }
                }
            });
        }