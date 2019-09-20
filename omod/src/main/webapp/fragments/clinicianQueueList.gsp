<%
    ui.includeCss("coreapps", "patientsearch/patientSearchWidget.css")
    if (clinicianLocation?.contains(currentLocation?.uuid)) {
%>
<style>
.card-body {
    -ms-flex: 1 1 auto;
    flex: 7 1 auto;
    padding: 1.0rem;
    background-color: #eee;
}

.my-tab .tab-pane {
    border: solid 1px blue;
}
.vertical {
    border-left: 1px solid #c7c5c5;
    height: 79px;
    position: absolute;
    left: 99%;
    top: 11%;
}
#patient-search {
    min-width: 96%;
    color: #363463;
    display: block;
    padding: 5px 10px;
    height: 45px;
    margin-top: 27px;
    background-color: #FFF;
    border: 1px solid #dddddd;
}
</style>
<script>
    if (jQuery) {
        setInterval(function () {
            console.log("Checking IF Reloading works");
            getPatientQueue();
        }, 3000);
        jq(document).ready(function () {

            jq('#add_patient_to_other_queue_dialog').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget);
                var patientId = button.data('patient-id');
                var modal = jq(this)
                modal.find("#patient_id").val(patientId);
            });
            setLocationsToSelect();

            getPatientQueue();
            jq("#patient-search").change(function () {
                if (jq("#patient-search").val().length >= 3) {
                    getPatientQueue();
                }
            });

            jq('#exampleModal').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget) // Button that triggered the modal
                var recipient = button.data('whatever') // Extract info from data-* attributes
                var order_id = button.data('order_id') // Extract info from data-* attributes
                jq("#order_id").val(order_id);
                jq("#sample_id").val("");
                jq("#reference_lab").prop('selectedIndex', 0);
                jq("#specimen_source_id").prop('selectedIndex', 0);
                jq("#refer_test input[type=checkbox]").prop('checked', false);
                // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
                // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
                var modal = jq(this)
                modal.find('.modal-title').text('New message to ' + order_id)
                modal.find('.modal-body input').val(order_id)
            })
        });
    }

    function getWaitingTime(queueDate) {
        var diff = Math.abs(new Date() - new Date(queueDate));
        var seconds = Math.floor(diff / 1000); //ignore any left over units smaller than a second
        var minutes = Math.floor(seconds / 60);
        var waitingTime = "";
        seconds = seconds % 60;
        var hours = Math.floor(minutes / 60);
        minutes = minutes % 60;

        if (hours > 0 || minutes > 60) {
            waitingTime = "<span style='background-color: red; color: white; width: 100%; text-align: center;'>" + hours + ":" + minutes + ":" + seconds + "</span>";
        } else {
            waitingTime = "<span style='background-color:green; color: white; width: 100%; text-align: center;'>" + hours + ":" + minutes + ":" + seconds + "</span>";
        }
        return waitingTime;
    }

    function getPatientQueue() {
        jq("#clinician-queue-list-table").html("");
        jq.get('${ ui.actionLink("getPatientQueueList") }', {
            searchfilter: jq("#patient-search").val().trim().toLowerCase()
        }, function (response) {
            if (response) {
                var responseData = JSON.parse(response.replace("patientClinicianQueueList=", "\"patientClinicianQueueList\":").trim());
                displayClinicianData(responseData);
            } else if (!response) {
                jq("#clinician-queue-list-table").append(${ ui.message("coreapps.none ") });
            }
        });
    }

    function setLocationsToSelect() {
        jq("#error_location_id").html("");
        jq("#location_id").html("");
        var content = "";
        content += "<option value=\"\">" + "${ui.message("Specimen Source")}" + "</option>";
        <% if (locationList.size() > 0) {
                      locationList.each { %>
        content += "<option value=\"${it.uuid}\">" + "${it.name}" + "</option>";
        <%} }else {%>
        jq("#error_location_id").append(${ui.message("patientqueueing.select.error")});
        <%}%>
        jq("#location_id").append(content);
    }

    function displayClinicianData(response) {
        jq("#clinician-queue-list-table").html("No Patient In  Pending List");
        jq("#clinician-completed-list-table").html("No Patient In Completed List");
        jq("#from-lab-list-table").html("No Patient In Lab List");
        var stillInQueueDataRows = "";
        var completedDataRows = "";
        var fromLabDataRows = "";
        stillInQueue = 0;
        completedQueue = 0;
        fromLabQueue = 0;
        var headerPending = "<table><thead><tr><th>VISIT ID</th><th>NAMES</th><th>GENDER</th><th>AGE</th><th>VISIT TYPE</th><th>ENTRY POINT</th><th>STATUS</th><th>WAITING TIME</th><th>ACTION</th></tr></thead><tbody>";
        var headerCompleted = "<table><thead><tr><th>VISIT ID</th><th>NAMES</th><th>GENDER</th><th>AGE</th><th>ENTRY POINT</th><th>COMPLETED TIME</th><th>ACTION</th></tr></thead><tbody>";
        var headerFromLab = "<table><thead><tr><th>VISIT ID</th><th>NAMES</th><th>GENDER</th><th>AGE</th><th>ENTRY POINT</th><th>COMPLETED TIME</th><th>ACTION</th></tr></thead><tbody>";
        var footer = "</tbody></table>";
        jq.each(response.patientClinicianQueueList, function (index, element) {
                var patientQueueListElement = element;
                var dataRowTable = "";
                var urlToPatientDashBoard = '${ui.pageLink("coreapps","clinicianfacing/patient",[patientId: "patientIdElement"])}'.replace("patientIdElement", element.patientId);
                var encounterUrl = "/" + OPENMRS_CONTEXT_PATH + "/htmlformentryui/htmlform/editHtmlFormWithStandardUi.page?patientId=" + element.patientId + "&formUuid=d514be1d-8a95-4f46-b8d8-9b8485679f47&encounterId=" + element.encounterId + "&returnUrl=/openmrs/patientqueueing/clinicianDashboard.page";

                var waitingTime = getWaitingTime(patientQueueListElement.dateCreated);
                dataRowTable += "<tr>";
                dataRowTable += "<td>" + patientQueueListElement.queueNumber.substring(15) + "</td>";
                dataRowTable += "<td>" + patientQueueListElement.patientNames + "</td>";
                dataRowTable += "<td>" + patientQueueListElement.gender + "</td>";
                dataRowTable += "<td>" + patientQueueListElement.age + "</td>";
                if (element.status !== "completed") {

                    if (patientQueueListElement.priorityComment != null) {
                        dataRowTable += "<td>" + patientQueueListElement.priorityComment + "</td>";
                    } else {
                        dataRowTable += "<td></td>";
                    }
                }
                dataRowTable += "<td>" + patientQueueListElement.locationFrom.substring(0, 3) + "</td>";
                dataRowTable += "<td>" + "" + "</td>";
                dataRowTable += "<td>" + waitingTime + "</td>";
                dataRowTable += "<td>";
                dataRowTable += "<i style=\"font-size: 25px;\" class=\"icon-dashboard view-action\" title=\"Goto Patient's Dashboard\" onclick=\"location.href = '" + urlToPatientDashBoard + "'\"></i>";
                dataRowTable += "<i  style=\"font-size: 25px;\" class=\"icon-external-link edit-action\" title=\"Send Patient To Another Location\" data-toggle=\"modal\" data-target=\"#add_patient_to_other_queue_dialog\" data-id=\"\" data-patient-id=\"%s\"></i>".replace("%s", element.patientId);
                if (element.status === "fromlab" || element.status === "completed") {
                    dataRowTable += "<i  style=\"font-size: 25px;\" class=\"icon-dashboard view-action\" title=\"Edit Patient Encounter\" onclick=\"location.href = '" + encounterUrl + "'\"></i>";
                }

                dataRowTable += "</td></tr>";

                if (element.status === "pending") {
                    stillInQueue += 1;
                    stillInQueueDataRows += dataRowTable;

                } else if (element.status === "completed") {
                    completedQueue += 1;
                    completedDataRows += dataRowTable;
                } else if (element.status === "fromlab") {
                    fromLabQueue += 1;
                    fromLabDataRows += dataRowTable;
                }
            }
        )
        ;

        if (stillInQueueDataRows !== "") {
            jq("#clinician-queue-list-table").html("");
            jq("#clinician-queue-list-table").append(headerPending + stillInQueueDataRows + footer);

        }

        if (fromLabDataRows !== "") {
            jq("#clinician-completed-list-table").html("");
            jq("#clinician-completed-list-table").append(headerCompleted + completedDataRows + footer);
        }

        if (completedDataRows !== "") {
            jq("#from-lab-list-table").html("");
            jq("#from-lab-list-table").append(headerFromLab + fromLabDataRows + footer);
        }


        jq("#clinician-pending-number").html("");
        jq("#clinician-pending-number").append("   " + stillInQueue);
        jq("#clinician-completed-number").html("");
        jq("#clinician-completed-number").append("   " + completedQueue);
        jq("#from-lab-number").html("");
        jq("#from-lab-number").append("   " + fromLabQueue);
    }
</script>
<br/>

<div class="card">
    <div class="card-header">
        <div class="">
            <div class="row">
                <div class="col-3">
                    <div>
                        <h1 style="color: maroon">${ui.message("Doctor's Queue:")}</i></h1>
                    </div>
                    <div>
                        <h2>${currentProvider?.personName?.fullName}</h2>
                    </div>
                    <div class="vertical"></div>
                </div>
                <div class="col-8">
                    <form method="get" id="patient-search-form" onsubmit="return false">
                        <input type="text" id="patient-search"
                               placeholder="${ui.message("coreapps.findPatient.search.placeholder")}" autocomplete="off"/><i
                            id="patient-search-clear-button" class="small icon-remove-sign"></i>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="card-body">
        <ul class="nav nav-tabs nav-fill" id="myTab" role="tablist">
            <li class="nav-item">
                <a class="nav-item nav-link active" id="home-tab" data-toggle="tab" href="#clinician-pending" role="tab"
                   aria-controls="clinician-pending-tab" aria-selected="true">Patients New <span style="color:red"
                                                                                                 id="clinician-pending-number">0</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="profile-tab" data-toggle="tab" href="#from-lab" role="tab"
                   aria-controls="from-lab-tab" aria-selected="false">Patients - Lab Results<span style="color:red"
                                                                                                  id="from-lab-number">0</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="contact-tab" data-toggle="tab" href="#clinician-completed" role="tab"
                   aria-controls="clinician-completed-number-tab" aria-selected="false">Patients - Completed<span
                        style="color:red" id="clinician-completed-number">0</span></a>
            </li>
        </ul>

        <div class="tab-content" id="myTabContent">
            <div class="tab-pane fade show active" id="clinician-pending" role="tabpanel"
                 aria-labelledby="clinician-pending-tab">
                <div class="info-body">
                    <div id="clinician-queue-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="from-lab" role="tabpanel" aria-labelledby="from-lab-tab">
                <div class="info-body">
                    <div id="from-lab-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="clinician-completed" role="tabpanel"
                 aria-labelledby="clinician-completed-tab">
                <div class="info-body">
                    <div id="clinician-completed-list-table">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
${ui.includeFragment("ugandaemrpoc", "addPatientToAnotherQueue")}
<% } %>