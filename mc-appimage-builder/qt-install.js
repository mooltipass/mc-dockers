function Controller() {
    installer.autoRejectMessageBoxes();
    installer.installationFinished.connect(function() {
        gui.clickButton(buttons.NextButton);
    })

    // Allow to cancel installation
    installer.setMessageBoxAutomaticAnswer("cancelInstallation", QMessageBox.Yes);

}

Controller.prototype.WelcomePageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.CredentialsPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.IntroductionPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.TargetDirectoryPageCallback = function() {
    gui.currentPageWidget().TargetDirectoryLineEdit.setText(installer.value("HomeDir") + "/Qt");
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.CredentialsPageCallback = function() {

    var login = installer.environmentVariable("QT_CI_LOGIN");
    var password = installer.environmentVariable("QT_CI_PASSWORD");

    if (login === "" || password === "") {
        gui.clickButton(buttons.CommitButton);
    }

    var widget = gui.currentPageWidget();

    widget.loginWidget.EmailLineEdit.setText(login);
    widget.loginWidget.PasswordLineEdit.setText(password);

    gui.clickButton(buttons.CommitButton);
}

Controller.prototype.ComponentSelectionPageCallback = function() {

    log("ComponentSelectionPageCallback");

    var list_packages = installer.environmentVariable("QT_CI_JUST_DO_LIST_PACKAGES");

    if (list_packages) {
      var components = installer.components();
      log("Available components: " + components.length);

      for (var i = 0 ; i < components.length ;i++) {
          log(components[i].name);
      }
      
      gui.clickButton(buttons.CancelButton);
      return;
    }


    log("Select components");

    function trim(str) {
        return str.replace(/^ +/,"").replace(/ *$/,"");
    }

    var widget = gui.currentPageWidget();

    var qt_ci_packages = installer.environmentVariable("QT_CI_PACKAGES");

    var packages = trim(qt_ci_packages).split(",");

    if (packages.length > 0 && packages[0] !== "") {
        widget.deselectAll();
        for (var i in packages) {
            var pkg = trim(packages[i]);
            log("Select " + pkg);
            widget.selectComponent(pkg);
        }
    } else {
       log("Use default component list");
    }

    gui.clickButton(buttons.NextButton);
}

Controller.prototype.LicenseAgreementPageCallback = function() {
    gui.currentPageWidget().AcceptLicenseRadioButton.setChecked(true);
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.StartMenuDirectoryPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.FinishedPageCallback = function() {
    var checkBoxForm = gui.currentPageWidget().LaunchQtCreatorCheckBoxForm
    if (checkBoxForm && checkBoxForm.launchQtCreatorCheckBox) {
        checkBoxForm.launchQtCreatorCheckBox.checked = false;
    }
    gui.clickButton(buttons.FinishButton);
}
