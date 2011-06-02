import "java.awt.GridLayout"
import "java.awt.Color"
import "java.awt.Dimension"
import "javax.swing.JPanel"
import "javax.swing.JLabel"

require 'lib/pophealth_importer_listener'
require 'lib/pophealth_individual_results_panel'

class PophealthSummaryPanel < JPanel

  def initialize
    super()
    self.setLayout(GridLayout.new(27,1))
    setup_summary_level_status
    setup_section_level_status
  end

  def update_analysis_results (analysis_results)
    @overall_validation_status.set_percentage(analysis_results["file_validation"])
    @allergies_present.set_percentage(analysis_results["allergies_present"])
    @allergies_coded.set_percentage(analysis_results["allergies_coded"])
    @allergies_mu_compliant.set_percentage(analysis_results["allergies_mu_compliant"])
    @encounters_present.set_percentage(analysis_results["encounters_present"])
    @encounters_coded.set_percentage(analysis_results["encounters_coded"])
    @encounters_mu_compliant.set_percentage(analysis_results["encounters_mu_compliant"])
    @conditions_present.set_percentage(analysis_results["conditions_present"])
    @conditions_coded.set_percentage(analysis_results["conditions_coded"])
    @conditions_mu_compliant.set_percentage(analysis_results["conditions_mu_compliant"])
    @lab_results_present.set_percentage(analysis_results["lab_results_present"])
    @lab_results_coded .set_percentage(analysis_results["lab_results_coded"])
    @lab_results_mu_compliant.set_percentage(analysis_results["lab_results_mu_compliant"])
    @immunizations_present.set_percentage(analysis_results["immunizations_present"])
    @immunizations_coded.set_percentage(analysis_results["immunizations_coded"])
    @immunizations_mu_compliant.set_percentage(analysis_results["immunizations_mu_compliant"])
    @medications_present.set_percentage(analysis_results["medications_present"])
    @medications_coded.set_percentage(analysis_results["medications_coded"])
    @medications_mu_compliant.set_percentage(analysis_results["medications_mu_compliant"])
    @procedures_present.set_percentage(analysis_results["procedures_present"])
    @procedures_coded.set_percentage(analysis_results["procedures_coded"])
    @procedures_mu_compliant.set_percentage(analysis_results["procedures_mu_compliant"])
    @vital_signs_present.set_percentage(analysis_results["vital_signs_present"])
    @vital_signs_coded.set_percentage(analysis_results["vital_signs_coded"])
    @vital_signs_mu_compliant.set_percentage(analysis_results["vital_signs_mu_compliant"])
    self.repaint
  end

  private

  def setup_summary_level_status
    # Summary Validation Status
    self.add(PophealthIndividualResultsPanel.new("File-Level Validation", false))
    if (PophealthImporterListener.continuity_of_care_mode == :c32_mode)
      @overall_validation_status = PophealthIndividualResultsPanel.new("Valid HITSP C32 XML Files:", true)
    else
      @overall_validation_status = PophealthIndividualResultsPanel.new("Valid ASTM CCR XML Files:", true)
    end
    self.add(@overall_validation_status)
  end

  def setup_section_level_status
    self.add(PophealthIndividualResultsPanel.new("Section-Level Reports", false))

    # Allergies
    @allergies_present = PophealthIndividualResultsPanel.new("Allergies Present:", true)
    @allergies_coded = PophealthIndividualResultsPanel.new("Allergies Coded:", true)
    @allergies_mu_compliant = PophealthIndividualResultsPanel.new("Allergies MU-Compliant:", true)
    self.add(@allergies_present)
    self.add(@allergies_coded)
    self.add(@allergies_mu_compliant)

    # Encounters
    @encounters_present = PophealthIndividualResultsPanel.new("Encounters Present:", true)
    @encounters_coded = PophealthIndividualResultsPanel.new("Encounters Coded:", true)
    @encounters_mu_compliant = PophealthIndividualResultsPanel.new("Encounters MU-Compliant:", true)
    self.add(@encounters_present)
    self.add(@encounters_coded)
    self.add(@encounters_mu_compliant)

    # Conditions
    @conditions_present = PophealthIndividualResultsPanel.new("Conditions Present:", true)
    @conditions_coded = PophealthIndividualResultsPanel.new("Conditions Coded:", true)
    @conditions_mu_compliant = PophealthIndividualResultsPanel.new("Conditions MU-Compliant:", true)
    self.add(@conditions_present)
    self.add(@conditions_coded)
    self.add(@conditions_mu_compliant)

    # Labs
    @lab_results_present = PophealthIndividualResultsPanel.new("Lab Results Present:", true)
    @lab_results_coded = PophealthIndividualResultsPanel.new("Lab Results Coded:", true)
    @lab_results_mu_compliant = PophealthIndividualResultsPanel.new("Lab Results MU-Compliant:", true)
    self.add(@lab_results_present)
    self.add(@lab_results_coded)
    self.add(@lab_results_mu_compliant)

    # Immunizations
    @immunizations_present = PophealthIndividualResultsPanel.new("Immunizations Present:", true)
    @immunizations_coded = PophealthIndividualResultsPanel.new("Immunizations Coded:", true)
    @immunizations_mu_compliant = PophealthIndividualResultsPanel.new("Immunizations MU-Compliant:", true)
    self.add(@immunizations_present)
    self.add(@immunizations_coded)
    self.add(@immunizations_mu_compliant)

    # Medications
    @medications_present = PophealthIndividualResultsPanel.new("Medications Present:", true)
    @medications_coded = PophealthIndividualResultsPanel.new("Medications Coded:", true)
    @medications_mu_compliant = PophealthIndividualResultsPanel.new("Medications MU-Compliant:", true)
    self.add(@medications_present)
    self.add(@medications_coded)
    self.add(@medications_mu_compliant)

    # Procedures
    @procedures_present = PophealthIndividualResultsPanel.new("Procedures Present:", true)
    @procedures_coded = PophealthIndividualResultsPanel.new("Procedures Coded:", true)
    @procedures_mu_compliant = PophealthIndividualResultsPanel.new("Procedures MU-Compliant:", true)
    self.add(@procedures_present)
    self.add(@procedures_coded)
    self.add(@procedures_mu_compliant)

    # Vital Signs
    @vital_signs_present = PophealthIndividualResultsPanel.new("Vital Signs Present:", true)
    @vital_signs_coded = PophealthIndividualResultsPanel.new("Vital Signs Coded:", true)
    @vital_signs_mu_compliant = PophealthIndividualResultsPanel.new("Vital Signs MU-Compliant:", true)
    self.add(@vital_signs_present)
    self.add(@vital_signs_coded)
    self.add(@vital_signs_mu_compliant)
  end

end