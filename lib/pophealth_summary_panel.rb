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

  private

  def setup_summary_level_status
    # Summary Validation Status
    self.add(PophealthIndividualResultsPanel.new("File-Level Validation", 0.0, false))
    if (PophealthImporterListener.continuity_of_care_mode == :c32_mode)
      @overall_validation_status = PophealthIndividualResultsPanel.new("Valid HITSP C32 XML Files:", 0.99, true)
    else
      @overall_validation_status = PophealthIndividualResultsPanel.new("Valid ASTM CCR XML Files:", 0.99, true)
    end
    self.add(@overall_validation_status)
  end

  def setup_section_level_status
    self.add(PophealthIndividualResultsPanel.new("Section-Level Reports", 0.0, false))

    # Allergies
    @allergies_present = PophealthIndividualResultsPanel.new("Allergies Present:", 1.0, true)
    @allergies_coded = PophealthIndividualResultsPanel.new("Allergies Coded:", 0.75, true)
    @allergies_mu_compliant = PophealthIndividualResultsPanel.new("Allergies MU-Compliant:", 0.0, true)
    self.add(@allergies_present)
    self.add(@allergies_coded)
    self.add(@allergies_mu_compliant)

    # Encounters
    @encounters_present = PophealthIndividualResultsPanel.new("Encounters Present:", 1.0, true)
    @encounters_coded = PophealthIndividualResultsPanel.new("Encounters Coded:", 0.75, true)
    @encounters_mu_compliant = PophealthIndividualResultsPanel.new("Encounters MU-Compliant:", 0.5, true)
    self.add(@encounters_present)
    self.add(@encounters_coded)
    self.add(@encounters_mu_compliant)

    # Conditions
    @conditions_present = PophealthIndividualResultsPanel.new("Conditions Present:", 1.0, true)
    @conditions_coded = PophealthIndividualResultsPanel.new("Conditions Coded:", 0.75, true)
    @conditions_mu_compliant = PophealthIndividualResultsPanel.new("Conditions MU-Compliant:", 0.5, true)
    self.add(@conditions_present)
    self.add(@conditions_coded)
    self.add(@conditions_mu_compliant)

    # Labs
    @lab_results_present = PophealthIndividualResultsPanel.new("Lab Results Present:", 1.0, true)
    @lab_results_coded = PophealthIndividualResultsPanel.new("Lab Results Coded:", 0.75, true)
    @lab_results_mu_compliant = PophealthIndividualResultsPanel.new("Lab Results MU-Compliant:", 0.5, true)
    self.add(@lab_results_present)
    self.add(@lab_results_coded)
    self.add(@lab_results_mu_compliant)

    # Immunizations
    @immunizations_present = PophealthIndividualResultsPanel.new("Immunizations Present:", 1.0, true)
    @immunizations_coded = PophealthIndividualResultsPanel.new("Immunizations Coded:", 0.75, true)
    @immunizations_mu_compliant = PophealthIndividualResultsPanel.new("Immunizations MU-Compliant:", 0.5, true)
    self.add(@immunizations_present)
    self.add(@immunizations_coded)
    self.add(@immunizations_mu_compliant)

    # Medications
    @medications_present = PophealthIndividualResultsPanel.new("Medications Present:", 1.0, true)
    @medications_coded = PophealthIndividualResultsPanel.new("Medications Coded:", 0.75, true)
    @medications_mu_compliant = PophealthIndividualResultsPanel.new("Medications MU-Compliant:", 0.5, true)
    self.add(@medications_present)
    self.add(@medications_coded)
    self.add(@medications_mu_compliant)

    # Procedures
    @procedures_present = PophealthIndividualResultsPanel.new("Procedures Present:", 1.0, true)
    @procedures_coded = PophealthIndividualResultsPanel.new("Procedures Coded:", 0.75, true)
    @procedures_mu_compliant = PophealthIndividualResultsPanel.new("Procedures MU-Compliant:", 0.5, true)
    self.add(@procedures_present)
    self.add(@procedures_coded)
    self.add(@procedures_mu_compliant)

    # Vital Signs
    @vital_signs_present = PophealthIndividualResultsPanel.new("Vital Signs Present:", 1.0, true)
    @vital_signs_coded = PophealthIndividualResultsPanel.new("Vital Signs Coded:", 0.75, true)
    @vital_signs_mu_compliant = PophealthIndividualResultsPanel.new("Vital Signs MU-Compliant:", 0.5, true)
    self.add(@vital_signs_present)
    self.add(@vital_signs_coded)
    self.add(@vital_signs_mu_compliant)
  end

end