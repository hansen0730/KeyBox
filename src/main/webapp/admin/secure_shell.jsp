<%
    /**
     * Copyright 2013 Sean Kavanagh - sean.p.kavanagh6@gmail.com
     *
     * Licensed under the Apache License, Version 2.0 (the "License");
     * you may not use this file except in compliance with the License.
     * You may obtain a copy of the License at
     *
     * http://www.apache.org/licenses/LICENSE-2.0
     *
     * Unless required by applicable law or agreed to in writing, software
     * distributed under the License is distributed on an "AS IS" BASIS,
     * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     * See the License for the specific language governing permissions and
     * limitations under the License.
     */
%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html>
<head>

<jsp:include page="../_res/inc/header.jsp"/>

<script type="text/javascript">
$(document).ready(function () {


    $("#set_password_dialog").dialog({
        autoOpen: false,
        height: 225,
        minWidth: 550,
        modal: true
    });
    $("#set_passphrase_dialog").dialog({
        autoOpen: false,
        height: 200,
        minWidth: 550,
        modal: true
    });
    $("#error_dialog").dialog({
        autoOpen: false,
        height: 225,
        minWidth: 550,
        modal: true
    });
    $("#upload_push_dialog").dialog({
        autoOpen: false,
        height: 375,
        minWidth: 725,
        modal: true,
        open: function (event, ui) {
            $(".ui-dialog-titlebar-close").show();
        },
        close: function () {
            $("#upload_push_frame").attr("src", "");
        }
    });

    $(".termwrapper").sortable({
        zIndex: 10000,
        helper: 'clone'
    }).disableSelection();


    $.ajaxSetup({ cache: false });
    $('.droppable').droppable({
        zIndex: 10000,
        tolerance: "touch",
        over: function (event, ui) {
            $('.ui-sortable-helper').addClass('dragdropHover');

        },
        out: function (event, ui) {
            $('.ui-sortable-helper').removeClass('dragdropHover');
        },

        drop: function (event, ui) {
            var id = ui.draggable.attr("id").replace("run_cmd_", "");
            $.ajax({ url: '../admin/disconnectTerm.action?id=' + id, cache: false});
            ui.draggable.remove();

        }
    });


    //submit add or edit form
    $(".submit_btn").button().click(function () {
        <s:if test="pendingSystemStatus!=null">
        $(this).parents('form:first').submit();
        </s:if>
        $("#error_dialog").dialog("close");
    });
    //close all forms
    $(".cancel_btn").button().click(function () {
        $("#set_password_dialog").dialog("close");
        window.location = 'getNextPendingSystemForTerms.action?pendingSystemStatus.id=<s:property value="pendingSystemStatus.id"/>&script.id=<s:if test="script!=null"><s:property value="script.id"/></s:if>';

    });


    //if terminal window toggle active for commands
    $(".run_cmd").click(function () {

        //check for cmd-click / ctr-click
        if (!keys[17] && !keys[91] && !keys[93] && !keys[224]) {
            $(".run_cmd").removeClass('run_cmd_active');
        }

        if ($(this).hasClass('run_cmd_active')) {
            $(this).removeClass('run_cmd_active');
        } else {
            $(this).addClass('run_cmd_active')
        }

    });

    $('#select_all').click(function () {
        $(".run_cmd").addClass('run_cmd_active');
    });


    $('#upload_push').click(function () {


        //get id list from selected terminals
        var ids = [];
        $(".run_cmd_active").each(function (index) {
            var id = $(this).attr("id").replace("run_cmd_", "");
            ids.push(id);
        });
        var idListStr = '?action=upload';
        ids.forEach(function (entry) {
            idListStr = idListStr + '&idList=' + entry;
        });

        $("#upload_push_frame").attr("src", "setUpload.action" + idListStr);
        $("#upload_push_dialog").dialog("open");


    });


    <s:if test="currentSystemStatus!=null && currentSystemStatus.statusCd=='GENERICFAIL'">
    $("#error_dialog").dialog("open");
    </s:if>
    <s:elseif test="pendingSystemStatus!=null">
    <s:if test="pendingSystemStatus.statusCd=='AUTHFAIL'">
    $("#set_password_dialog").dialog("open");
    </s:if>
    <s:elseif test="pendingSystemStatus.statusCd=='KEYAUTHFAIL'">
    $("#set_passphrase_dialog").dialog("open");
    </s:elseif>
    <s:else>
    <s:if test="currentSystemStatus==null ||currentSystemStatus.statusCd!='GENERICFAIL'">
    $("#composite_terms_frm").submit();
    </s:if>
    </s:else>
    </s:elseif>






    <s:if test="pendingSystemStatus==null">

    $('#dummy').focus();
    var keys = {};


    var termFocus = true;
    $("#match").focus(function () {
        termFocus = false;
    });
    $("#match").blur(function () {
        termFocus = true;
    });


    $(document).keypress(function (e) {
        if (termFocus) {
            var keyCode = (e.keyCode) ? e.keyCode : e.charCode;

            var idList = [];
            $(".run_cmd_active").each(function (index) {
                var id = $(this).attr("id").replace("run_cmd_", "");
                idList.push(id);
            });

            if (String.fromCharCode(keyCode) && String.fromCharCode(keyCode) != ''
                    && !keys[91] && !keys[93] && !keys[224] && !keys[27]
                    && !keys[37] && !keys[38] && !keys[39] && !keys[40]
                    && !keys[13] && !keys[8] && !keys[9] && !keys[17]) {
                var cmdStr = String.fromCharCode(keyCode);
                connection.send(JSON.stringify({id: idList, command: cmdStr}));
            }

        }
    });
    //function for command keys (ie ESC, CTRL, etc..)
    $(document).keydown(function (e) {
        if (termFocus) {
            var keyCode = (e.keyCode) ? e.keyCode : e.charCode;
            keys[keyCode] = true;
            //27 - ESC
            //37 - LEFT
            //38 - UP
            //39 - RIGHT
            //40 - DOWN
            //13 - ENTER
            //8 - DEL
            //9 - TAB
            //17 - CTRL
            if (keys[27] || keys[37] || keys[38] || keys[39] || keys[40] || keys[13] || keys[8] || keys[9] || keys[17]) {
                var idList = [];
                $(".run_cmd_active").each(function (index) {
                    var id = $(this).attr("id").replace("run_cmd_", "");
                    idList.push(id);
                });

                connection.send(JSON.stringify({id: idList, keyCode: keyCode}));
            }
        }

    });

    $(document).keyup(function (e) {
        var keyCode = (e.keyCode) ? e.keyCode : e.charCode;
        delete keys[keyCode];
        if (termFocus) {
            $('#dummy').focus();
        }
    });

    $(document).click(function (e) {
        if (!$(e.target).is('#match')) {
            $('#dummy').focus();
        }

    });


    //get cmd text from paste
    $("#dummy").bind('paste', function (e) {
        $('#dummy').val('');
        setTimeout(function () {
            var idList = [];
            $(".run_cmd_active").each(function (index) {
                var id = $(this).attr("id").replace("run_cmd_", "");
                idList.push(id);
            });
            var cmdStr = $('#dummy').val();
            connection.send(JSON.stringify({id: idList, command: cmdStr}));
        }, 100);
    });


    var termMap = {};

    $(".output").each(function (index) {
        var id = $(this).attr("id").replace("output_", "");
        termMap[id] = new Terminal(80, 24);
        termMap[id].open($(this));
    });


    var loc = window.location, ws_uri;
    if (loc.protocol === "https:") {
        ws_uri = "wss:";
    } else {
        ws_uri = "ws:";
    }
    ws_uri += "//" + loc.host + '/terms.ws?t=' + new Date().getTime();

    var connection = new WebSocket(ws_uri);


    // Log errors
    connection.onerror = function (error) {
        console.log('WebSocket Error ' + error);
    };

    // Log messages from the server
    connection.onmessage = function (e) {
        var json = jQuery.parseJSON(e.data);
        $.each(json, function (key, val) {
            if (val.output != '') {
                termMap[val.hostSystemId].write(val.output);
            }
        });

    };

    $('#match_btn').unbind().click(function () {
        $('#match_frm').submit();
    });

    $('#match_frm').submit(function () {
        runRegExMatch();
        return false;
    });


    var matchFunction = null;

    function runRegExMatch() {

        if ($('#match_btn').hasClass('btn-success')) {

            $('#match_btn').switchClass('btn-success', 'btn-danger', 0);
            $('#match_btn').text("Stop");

            matchFunction = setInterval(function () {

                var termMap = [];
                var existingTerms = [];
                $(".run_cmd").each(function () {
                    var matchRegEx = null;
                    try {
                        matchRegEx = new RegExp($('#match').val(), 'g');
                    } catch (ex) {
                    }
                    if (matchRegEx != null) {
                        var attrId = $(this).attr("id");
                        if (attrId && attrId != '') {
                            var id = attrId.replace("run_cmd_", "");

                            var match = $('#output_' + id + ' > .terminal').text().match(matchRegEx);

                            if (match != null) {
                                termMap.push({id: id, no_matches: match.length});
                            }
                            existingTerms.push({id: id});
                        }
                    }
                });


                var sorted = termMap.slice(0).sort(function (a, b) {
                    return a.no_matches - b.no_matches;
                });


                for (var i = 0; i < sorted.length; ++i) {
                    var termId = sorted[i].id;
                    $('#run_cmd_' + termId).prependTo('.termwrapper');
                    if (sorted[sorted.length - i - 1].id != existingTerms[i].id) {
                        $('#run_cmd_' + termId).fadeTo(100, .5).fadeTo(100, 1);
                    }
                }


            }, 5000);


        } else {
            $('#match_btn').switchClass('btn-danger', 'btn-success', 0);
            $('#match_btn').text("Start");
            clearInterval(matchFunction)
        }

    }


    </s:if>

});


</script>

<style>
    .dragdropHover {
        background-color: red;
    }

    .align-right {
        padding: 10px 2px 10px 10px;
        float: right;
    }
</style>

<title>KeyBox - Composite Terms</title>

</head>
<body>
<s:if test="(systemList!= null && !systemList.isEmpty()) || pendingSystemStatus!=null">

    <div class="navbar navbar-default navbar-fixed-top" role="navigation">
        <div class="container">

            <div class="navbar-header">
                <div class="navbar-brand">
                    <div class="nav-img"><img src="<%= request.getContextPath() %>/img/keybox_50x38.png"/></div>
                    KeyBox
                </div>
            </div>
            <div class="collapse navbar-collapse">
                <s:if test="pendingSystemStatus==null">


                    <ul class="nav navbar-nav">
                        <li><a id="select_all" href="#">Select All</a></li>
                        <li><a id="upload_push" href="#">Upload &amp; Push</a></li>
                        <li><a href="exitTerms.action">Exit Terminals</a></li>
                    </ul>
                    <div class="droppable align-right">
                        <a href="#" title="Drag to disconnect">
                            <img src="<%= request.getContextPath() %>/img/disconnect.png"/></a></div>
                    <div class="note">Use CMD-Click or CTRL-Click to select multiple individual terminals<br/>Drag
                        terminal window to icon to disconnect
                    </div>
                    <div class="clear"></div>
                </s:if>
            </div>
            <!--/.nav-collapse -->
        </div>
    </div>
    <div class="container">

        <div class="align-right">

            <div style="float:right;margin:0;padding:0">
                <textarea name="dummy" id="dummy" size="1"
                          style="border:none;color:#FFFFFF;width:1px;height:1px"></textarea>
                <input type="text" name="dummy2" id="dummy2" size="1"
                       style="border:none;color:#FFFFFF;width:1px;height:1px"/>
            </div>
            <div style="float:right">
                <s:form id="match_frm" theme="simple">
                    <label>Sort By</label>&nbsp;&nbsp;<s:textfield id="match" name="match"
                                                                   placeholder="Bring terminals to top that match RegExp"
                                                                   size="40"
                                                                   theme="simple"/>
                    <div id="match_btn" class="btn btn-success">Start</div>
                </s:form>
            </div>


        </div>

    </div>

    <div class="container" style="width:100%;padding: 0px; margin: 0px;border:none;">


        <div class="termwrapper">
            <s:iterator value="systemList">
                <div id="run_cmd_<s:property value="id"/>" class="run_cmd_active run_cmd">

                    <h4><s:property value="displayLabel"/></h4>

                    <div id="term" class="term">
                        <div id="output_<s:property value="id"/>" class="output"></div>
                    </div>

                </div>
            </s:iterator>
        </div>


        <div id="upload_push_dialog" title="Upload &amp; Push">
            <iframe id="upload_push_frame" width="700px" height="300px" style="border: none;">

            </iframe>


        </div>


    </div>
</s:if>
<s:else>
    <jsp:include page="../_res/inc/navigation.jsp"/>

    <div class="container">
        <h3>Composite SSH Terms</h3>

        <p class="error">No sessions could be created</p>
    </div>
</s:else>

<div id="set_password_dialog" title="Enter Password">
    <p class="error"><s:property value="pendingSystemStatus.errorMsg"/></p>

    <p>Enter password for <s:property value="pendingSystemStatus.displayLabel"/>

    </p>
    <s:form id="password_frm" action="createTerms">
        <s:hidden name="pendingSystemStatus.id"/>
        <s:password name="password" label="Password" size="15" value="" autocomplete="off"/>
        <s:if test="script!=null">
            <s:hidden name="script.id"/>
        </s:if>
        <tr>
            <td>&nbsp;</td>
            <td align="left">
                <div class="btn btn-default submit_btn">Submit</div>
                <div class="btn btn-default cancel_btn">Cancel</div>
            </td>
        </tr>
    </s:form>
</div>

<div id="set_passphrase_dialog" title="Enter Passphrase">
    <p class="error"><s:property value="pendingSystemStatus.errorMsg"/></p>

    <p>Enter passphrase for <s:property value="pendingSystemStatus.displayLabel"/></p>
    <s:form id="passphrase_frm" action="createTerms">
        <s:hidden name="pendingSystemStatus.id"/>
        <s:password name="passphrase" label="Passphrase" size="15" value="" autocomplete="off"/>
        <s:if test="script!=null">
            <s:hidden name="script.id"/>
        </s:if>
        <tr>
            <td>&nbsp;</td>
            <td align="left">
                <div class="btn btn-default submit_btn">Submit</div>
                <div class="btn btn-default cancel_btn">Cancel</div>
            </td>
        </tr>
    </s:form>
</div>

<div id="error_dialog" title="Error">
    <p class="error">Error: <s:property value="currentSystemStatus.errorMsg"/></p>

    <p>System: <s:property value="currentSystemStatus.displayLabel"/>

    </p>

    <s:form id="error_frm" action="createTerms">
        <s:hidden name="pendingSystemStatus.id"/>
        <s:if test="script!=null">
            <s:hidden name="script.id"/>
        </s:if>
        <tr>
            <td colspan="2">
                <div class="btn btn-default submit_btn">OK</div>
            </td>
        </tr>
    </s:form>
</div>

<s:form id="composite_terms_frm" action="createTerms">
    <s:hidden name="pendingSystemStatus.id"/>
    <s:if test="script!=null">
        <s:hidden name="script.id"/>
    </s:if>
</s:form>

</body>
</html>
