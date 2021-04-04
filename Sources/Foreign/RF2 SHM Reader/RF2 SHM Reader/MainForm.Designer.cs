/*
MainForm Designer part of file.

Author: The Iron Wolf (vleonavicius@hotmail.com)
Website: thecrewchief.org
*/
namespace rF2SMMonitor
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
      this.view = new System.Windows.Forms.PictureBox();
      this.scaleLabel = new System.Windows.Forms.Label();
      this.scaleTextBox = new System.Windows.Forms.TextBox();
      this.focusVehLabel = new System.Windows.Forms.Label();
      this.focusVehTextBox = new System.Windows.Forms.TextBox();
      this.setAsOriginCheckBox = new System.Windows.Forms.CheckBox();
      this.groupBoxFocus = new System.Windows.Forms.GroupBox();
      this.rotateAroundCheckBox = new System.Windows.Forms.CheckBox();
      this.globalGroupBox = new System.Windows.Forms.GroupBox();
      this.yOffsetTextBox = new System.Windows.Forms.TextBox();
      this.yOffsetLabel = new System.Windows.Forms.Label();
      this.xOffsetTextBox = new System.Windows.Forms.TextBox();
      this.xOffsetLabel = new System.Windows.Forms.Label();
      this.loggingGroupBox = new System.Windows.Forms.GroupBox();
      this.logRulesCheckBox = new System.Windows.Forms.CheckBox();
      this.logTimingCheckBox = new System.Windows.Forms.CheckBox();
      this.logDamageCheckBox = new System.Windows.Forms.CheckBox();
      this.logPhaseAndStateCheckBox = new System.Windows.Forms.CheckBox();
      this.lightModeCheckBox = new System.Windows.Forms.CheckBox();
      this.inputsGroupBox = new System.Windows.Forms.GroupBox();
      this.enablePitInputsCheckBox = new System.Windows.Forms.CheckBox();
      this.enablePitInputsToolTip = new System.Windows.Forms.ToolTip();
      this.rainIntensityLabel = new System.Windows.Forms.Label();
      this.rainIntensityTextBox = new System.Windows.Forms.TextBox();
      this.applyRainIntensityButton = new System.Windows.Forms.Button();
    ((System.ComponentModel.ISupportInitialize)(this.view)).BeginInit();
      this.groupBoxFocus.SuspendLayout();
      this.globalGroupBox.SuspendLayout();
      this.loggingGroupBox.SuspendLayout();
      this.SuspendLayout();
      // 
      // view
      // 
      this.view.Location = new System.Drawing.Point(-1, 56);
      this.view.Name = "view";
      this.view.Size = new System.Drawing.Size(1902, 975);
      this.view.TabIndex = 0;
      this.view.TabStop = false;
      // 
      // scaleLabel
      // 
      this.scaleLabel.AutoSize = true;
      this.scaleLabel.Location = new System.Drawing.Point(6, 17);
      this.scaleLabel.Name = "scaleLabel";
      this.scaleLabel.Size = new System.Drawing.Size(37, 13);
      this.scaleLabel.TabIndex = 1;
      this.scaleLabel.Text = "Scale:";
      // 
      // scaleTextBox
      // 
      this.scaleTextBox.AcceptsReturn = true;
      this.scaleTextBox.Location = new System.Drawing.Point(49, 14);
      this.scaleTextBox.Name = "scaleTextBox";
      this.scaleTextBox.Size = new System.Drawing.Size(61, 20);
      this.scaleTextBox.TabIndex = 2;
      // 
      // focusVehLabel
      // 
      this.focusVehLabel.AutoSize = true;
      this.focusVehLabel.Location = new System.Drawing.Point(7, 18);
      this.focusVehLabel.Name = "focusVehLabel";
      this.focusVehLabel.Size = new System.Drawing.Size(55, 13);
      this.focusVehLabel.TabIndex = 3;
      this.focusVehLabel.Text = "Vehicle #:";
      // 
      // focusVehTextBox
      // 
      this.focusVehTextBox.Location = new System.Drawing.Point(67, 16);
      this.focusVehTextBox.Name = "focusVehTextBox";
      this.focusVehTextBox.Size = new System.Drawing.Size(54, 20);
      this.focusVehTextBox.TabIndex = 4;
      // 
      // setAsOriginCheckBox
      // 
      this.setAsOriginCheckBox.AutoSize = true;
      this.setAsOriginCheckBox.Location = new System.Drawing.Point(129, 13);
      this.setAsOriginCheckBox.Name = "setAsOriginCheckBox";
      this.setAsOriginCheckBox.Size = new System.Drawing.Size(86, 17);
      this.setAsOriginCheckBox.TabIndex = 6;
      this.setAsOriginCheckBox.Text = "Set as Origin";
      this.setAsOriginCheckBox.UseVisualStyleBackColor = true;
      // 
      // groupBoxFocus
      // 
      this.groupBoxFocus.Controls.Add(this.rotateAroundCheckBox);
      this.groupBoxFocus.Controls.Add(this.focusVehTextBox);
      this.groupBoxFocus.Controls.Add(this.setAsOriginCheckBox);
      this.groupBoxFocus.Controls.Add(this.focusVehLabel);
      this.groupBoxFocus.Location = new System.Drawing.Point(433, -1);
      this.groupBoxFocus.Name = "groupBoxFocus";
      this.groupBoxFocus.Size = new System.Drawing.Size(265, 54);
      this.groupBoxFocus.TabIndex = 7;
      this.groupBoxFocus.TabStop = false;
      this.groupBoxFocus.Text = "Focus";
      // 
      // rotateAroundCheckBox
      // 
      this.rotateAroundCheckBox.AutoSize = true;
      this.rotateAroundCheckBox.Location = new System.Drawing.Point(129, 32);
      this.rotateAroundCheckBox.Name = "rotateAroundCheckBox";
      this.rotateAroundCheckBox.Size = new System.Drawing.Size(129, 17);
      this.rotateAroundCheckBox.TabIndex = 8;
      this.rotateAroundCheckBox.Text = "Set as Rotation Origin";
      this.rotateAroundCheckBox.UseVisualStyleBackColor = true;
      // 
      // globalGroupBox
      // 
      this.globalGroupBox.Controls.Add(this.yOffsetTextBox);
      this.globalGroupBox.Controls.Add(this.yOffsetLabel);
      this.globalGroupBox.Controls.Add(this.xOffsetTextBox);
      this.globalGroupBox.Controls.Add(this.xOffsetLabel);
      this.globalGroupBox.Controls.Add(this.scaleTextBox);
      this.globalGroupBox.Controls.Add(this.scaleLabel);
      this.globalGroupBox.Location = new System.Drawing.Point(89, -1);
      this.globalGroupBox.Name = "globalGroupBox";
      this.globalGroupBox.Size = new System.Drawing.Size(335, 54);
      this.globalGroupBox.TabIndex = 8;
      this.globalGroupBox.TabStop = false;
      this.globalGroupBox.Text = "Global";
      // 
      // yOffsetTextBox
      // 
      this.yOffsetTextBox.Location = new System.Drawing.Point(272, 14);
      this.yOffsetTextBox.Name = "yOffsetTextBox";
      this.yOffsetTextBox.Size = new System.Drawing.Size(51, 20);
      this.yOffsetTextBox.TabIndex = 6;
      // 
      // yOffsetLabel
      // 
      this.yOffsetLabel.AutoSize = true;
      this.yOffsetLabel.Location = new System.Drawing.Point(226, 18);
      this.yOffsetLabel.Name = "yOffsetLabel";
      this.yOffsetLabel.Size = new System.Drawing.Size(44, 13);
      this.yOffsetLabel.TabIndex = 5;
      this.yOffsetLabel.Text = "y offset:";
      // 
      // xOffsetTextBox
      // 
      this.xOffsetTextBox.Location = new System.Drawing.Point(169, 14);
      this.xOffsetTextBox.Name = "xOffsetTextBox";
      this.xOffsetTextBox.Size = new System.Drawing.Size(51, 20);
      this.xOffsetTextBox.TabIndex = 4;
      // 
      // xOffsetLabel
      // 
      this.xOffsetLabel.AutoSize = true;
      this.xOffsetLabel.Location = new System.Drawing.Point(123, 18);
      this.xOffsetLabel.Name = "xOffsetLabel";
      this.xOffsetLabel.Size = new System.Drawing.Size(44, 13);
      this.xOffsetLabel.TabIndex = 3;
      this.xOffsetLabel.Text = "x offset:";
      // 
      // groupBoxLogging
      // 
      this.loggingGroupBox.Controls.Add(this.logRulesCheckBox);
      this.loggingGroupBox.Controls.Add(this.logTimingCheckBox);
      this.loggingGroupBox.Controls.Add(this.logDamageCheckBox);
      this.loggingGroupBox.Controls.Add(this.logPhaseAndStateCheckBox);
      this.loggingGroupBox.Location = new System.Drawing.Point(706, -1);
      this.loggingGroupBox.Name = "groupBoxLogging";
      this.loggingGroupBox.Size = new System.Drawing.Size(256, 54);
      this.loggingGroupBox.TabIndex = 9;
      this.loggingGroupBox.TabStop = false;
      this.loggingGroupBox.Text = "File Logging";
      // 
      // checkBoxLogRules
      // 
      this.logRulesCheckBox.AutoSize = true;
      this.logRulesCheckBox.Location = new System.Drawing.Point(109, 32);
      this.logRulesCheckBox.Name = "checkBoxLogRules";
      this.logRulesCheckBox.Size = new System.Drawing.Size(53, 17);
      this.logRulesCheckBox.TabIndex = 12;
      this.logRulesCheckBox.Text = "Rules";
      this.logRulesCheckBox.UseVisualStyleBackColor = true;
      // 
      // checkBoxLogTiming
      // 
      this.logTimingCheckBox.AutoSize = true;
      this.logTimingCheckBox.Location = new System.Drawing.Point(109, 13);
      this.logTimingCheckBox.Name = "checkBoxLogTiming";
      this.logTimingCheckBox.Size = new System.Drawing.Size(57, 17);
      this.logTimingCheckBox.TabIndex = 11;
      this.logTimingCheckBox.Text = "Timing";
      this.logTimingCheckBox.UseVisualStyleBackColor = true;
      // 
      // checkBoxLogDamage
      // 
      this.logDamageCheckBox.AutoSize = true;
      this.logDamageCheckBox.Location = new System.Drawing.Point(7, 32);
      this.logDamageCheckBox.Name = "checkBoxLogDamage";
      this.logDamageCheckBox.Size = new System.Drawing.Size(66, 17);
      this.logDamageCheckBox.TabIndex = 10;
      this.logDamageCheckBox.Text = "Damage";
      this.logDamageCheckBox.UseVisualStyleBackColor = true;
      // 
      // checkBoxLogPhaseAndState
      // 
      this.logPhaseAndStateCheckBox.AutoSize = true;
      this.logPhaseAndStateCheckBox.Location = new System.Drawing.Point(7, 13);
      this.logPhaseAndStateCheckBox.Name = "checkBoxLogPhaseAndState";
      this.logPhaseAndStateCheckBox.Size = new System.Drawing.Size(105, 17);
      this.logPhaseAndStateCheckBox.TabIndex = 9;
      this.logPhaseAndStateCheckBox.Text = "Phase and State";
      this.logPhaseAndStateCheckBox.UseVisualStyleBackColor = true;
      // 
      // checkBoxLightMode
      // 
      this.lightModeCheckBox.AutoSize = true;
      this.lightModeCheckBox.Location = new System.Drawing.Point(5, 6);
      this.lightModeCheckBox.Name = "checkBoxLightMode";
      this.lightModeCheckBox.Size = new System.Drawing.Size(78, 17);
      this.lightModeCheckBox.TabIndex = 11;
      this.lightModeCheckBox.Text = "Light mode";
      this.lightModeCheckBox.UseVisualStyleBackColor = true;
      // 
      // groupBoxInputs
      // 
      this.inputsGroupBox.Controls.Add(this.enablePitInputsCheckBox);
      this.inputsGroupBox.Controls.Add(this.rainIntensityLabel);
      this.inputsGroupBox.Controls.Add(this.rainIntensityTextBox);
      this.inputsGroupBox.Controls.Add(this.applyRainIntensityButton);
      this.inputsGroupBox.Location = new System.Drawing.Point(972, -1);
      this.inputsGroupBox.Name = "groupBoxInputs";
      this.inputsGroupBox.Size = new System.Drawing.Size(256, 54);
      this.inputsGroupBox.TabIndex = 15;
      this.inputsGroupBox.TabStop = false;
      this.inputsGroupBox.Text = "Inputs";
      // 
      // checkBoxEnablePitInputs
      // 
      this.enablePitInputsCheckBox.AutoSize = true;
      this.enablePitInputsCheckBox.Location = new System.Drawing.Point(7, 13);
      this.enablePitInputsCheckBox.Name = "checkBoxEnablePitInputs";
      this.enablePitInputsCheckBox.Size = new System.Drawing.Size(53, 17);
      this.enablePitInputsCheckBox.TabIndex = 20;
      this.enablePitInputsCheckBox.Text = "Enable Pit Inputs";
      this.enablePitInputsCheckBox.UseVisualStyleBackColor = true;
      this.enablePitInputsCheckBox.Checked = false;
      this.enablePitInputsToolTip.SetToolTip(this.enablePitInputsCheckBox, "Control rF2 Pit menu using Y, U, O and P keys.  Note that Pit Menu buffer and EnableHWControlInput should be enabled.");
      // 
      // rainIntensityLabel
      // 
      this.rainIntensityLabel.AutoSize = true;
      this.rainIntensityLabel.Location = new System.Drawing.Point(5, 32);
      this.rainIntensityLabel.Name = "rainIntensityLabel";
      this.rainIntensityLabel.Size = new System.Drawing.Size(44, 13);
      this.rainIntensityLabel.TabIndex = 25;
      this.rainIntensityLabel.Text = "Rain intensity:";
      // 
      // rainIntensityTextBox
      // 
      this.rainIntensityTextBox.Location = new System.Drawing.Point(80, 30);
      this.rainIntensityTextBox.Name = "rainIntensityTextBox";
      this.rainIntensityTextBox.Size = new System.Drawing.Size(40, 20);
      this.rainIntensityTextBox.TabIndex = 30;
      // 
      // applyRainIntensityButton
      // 
      this.applyRainIntensityButton.Location = new System.Drawing.Point(125, 29);
      this.applyRainIntensityButton.Name = "applyRainIntensityButton";
      this.applyRainIntensityButton.Size = new System.Drawing.Size(70, 22);
      this.applyRainIntensityButton.TabIndex = 35;
      this.applyRainIntensityButton.Text = "Apply";
      this.applyRainIntensityButton.Enabled = false;
      // 
      // MainForm
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(1902, 1033);
      this.Controls.Add(this.lightModeCheckBox);
      this.Controls.Add(this.loggingGroupBox);
      this.Controls.Add(this.globalGroupBox);
      this.Controls.Add(this.groupBoxFocus);
      this.Controls.Add(this.inputsGroupBox);
      this.Controls.Add(this.view);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
      this.MaximizeBox = false;
      this.Name = "MainForm";
      this.Text = "rF2 Shared Memory Monitor";
      ((System.ComponentModel.ISupportInitialize)(this.view)).EndInit();
      this.groupBoxFocus.ResumeLayout(false);
      this.groupBoxFocus.PerformLayout();
      this.globalGroupBox.ResumeLayout(false);
      this.globalGroupBox.PerformLayout();
      this.loggingGroupBox.ResumeLayout(false);
      this.loggingGroupBox.PerformLayout();
      this.ResumeLayout(false);
      this.PerformLayout();

        }

    #endregion

    private System.Windows.Forms.PictureBox view;
    private System.Windows.Forms.Label scaleLabel;
    private System.Windows.Forms.TextBox scaleTextBox;
    private System.Windows.Forms.Label focusVehLabel;
    private System.Windows.Forms.TextBox focusVehTextBox;
    private System.Windows.Forms.CheckBox setAsOriginCheckBox;
    private System.Windows.Forms.GroupBox groupBoxFocus;
    private System.Windows.Forms.CheckBox rotateAroundCheckBox
;
    private System.Windows.Forms.GroupBox globalGroupBox;
    private System.Windows.Forms.TextBox xOffsetTextBox;
    private System.Windows.Forms.Label xOffsetLabel;
    private System.Windows.Forms.TextBox yOffsetTextBox;
    private System.Windows.Forms.Label yOffsetLabel;
    private System.Windows.Forms.GroupBox loggingGroupBox;
    private System.Windows.Forms.CheckBox logPhaseAndStateCheckBox;
    private System.Windows.Forms.CheckBox lightModeCheckBox;
    private System.Windows.Forms.CheckBox logDamageCheckBox;
    private System.Windows.Forms.CheckBox logTimingCheckBox;
    private System.Windows.Forms.CheckBox logRulesCheckBox;
    private System.Windows.Forms.GroupBox inputsGroupBox;
    private System.Windows.Forms.CheckBox enablePitInputsCheckBox;
    private System.Windows.Forms.ToolTip enablePitInputsToolTip;
    private System.Windows.Forms.Label rainIntensityLabel;
    private System.Windows.Forms.TextBox rainIntensityTextBox;
    private System.Windows.Forms.Button applyRainIntensityButton;
  }
}

