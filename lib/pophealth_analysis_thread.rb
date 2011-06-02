import "java.lang.Thread"
import "javax.swing.JOptionPane"

class PophealthAnalysisThread < Thread

  def initialize
    @schematron_validator = Validation::ValidatorRegistry.c32_schematron_validator
    @schema_validator = Validation::ValidatorRegistry.c32_xml_schema_validator
  end

  def set_parent_jframe(parent_jframe)
    @pophealth_jframe = parent_jframe
  end

  def set_import_directory(import_directory)
    @import_directory = import_directory
  end

  def run
    files = @import_directory.listFiles()
    if (files && (files.size > 0))
      analyze_data(files)
    else
      JOptionPane.showMessageDialog(@pophealth_jframe,
        "Directory selected '" + @import_directory.to_s +
          " does not have any files in it.\nPlease select a directory " +
          "with either your patient C32 or CCR Continuity of Care XML records",
        "popHealth: Invalid Data Input Directory Selection",
        JOptionPane::WARNING_MESSAGE)
    end
  end

  private

  def analyze_data(files)
    analysis_results = prime_analysis_results
    file_counter = 0
    file_validation_errors = 0
    # iterate over the files in the selected directory
    files.each do |next_file|
      puts "Considering " + next_file.to_s
      continuity_of_care_record = File.read(next_file.get_path)
      if (PophealthImporterListener.continuity_of_care_mode == :c32_mode)
        c32_schema_errors= @schema_validator.validate(continuity_of_care_record)
        c32_schematron_errors = @schematron_validator.validate(continuity_of_care_record)
        if (c32_schema_errors.size > 0 || c32_schematron_errors.size > 0)
          file_validation_errors += 1
        end
        doc = Nokogiri::XML(continuity_of_care_record)
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        patient_summary_report = Stats::PatientSummaryReport.from_c32(doc)
        update_analysis_results(patient_summary_report, analysis_results)
      else
        puts "Insert logic to consider CCR file"
      end
      file_counter += 1
      @pophealth_jframe.set_analysis_progress_bar((file_counter.to_f)/(files.size.to_f))
      @pophealth_jframe.get_content_pane.repaint()
    end
    analysis_results["number_files"] =    files.size
    analysis_results["file_validation"] = files.size-file_validation_errors
    @pophealth_jframe.update_analysis_results(analysis_results)
    @pophealth_jframe.enable_play
    @pophealth_jframe.set_analysis_progress_bar(0)
  end

  def update_analysis_results(patient_summary_report, analysis_results)
    if (patient_summary_report.allergies)
      analysis_results["allergies_present"] +=          patient_summary_report.allergies.entries.size
      analysis_results["allergies_coded"] +=            patient_summary_report.allergies.num_coded_entries
      analysis_results["allergies_mu_compliant"] +=     patient_summary_report.allergies.mu_coded_entries.size
    end
    if (patient_summary_report.encounters)
      analysis_results["encounters_present"] +=         patient_summary_report.encounters.entries.size
      analysis_results["encounters_coded"] +=           patient_summary_report.encounters.num_coded_entries
      analysis_results["encounters_mu_compliant"] +=    patient_summary_report.encounters.mu_coded_entries.size
    end
    if (patient_summary_report.conditions)
      analysis_results["conditions_present"] +=         patient_summary_report.conditions.entries.size
      analysis_results["conditions_coded"] +=           patient_summary_report.conditions.num_coded_entries
      analysis_results["conditions_mu_compliant"] +=    patient_summary_report.conditions.mu_coded_entries.size
    end
    if (patient_summary_report.results)
      analysis_results["lab_results_present"] +=        patient_summary_report.conditions.entries.size
      analysis_results["lab_results_coded"] +=          patient_summary_report.conditions.num_coded_entries
      analysis_results["lab_results_mu_compliant"] +=   patient_summary_report.conditions.mu_coded_entries.size
    end
    if (patient_summary_report.immunizations)
      analysis_results["immunizations_present"] +=      patient_summary_report.immunizations.entries.size
      analysis_results["immunizations_coded"] +=        patient_summary_report.immunizations.num_coded_entries
      analysis_results["immunizations_mu_compliant"] += patient_summary_report.immunizations.mu_coded_entries.size
    end
    if (patient_summary_report.medications)
      analysis_results["medications_present"] +=        patient_summary_report.medications.entries.size
      analysis_results["medications_coded"] +=          patient_summary_report.medications.num_coded_entries
      analysis_results["medications_mu_compliant"] +=   patient_summary_report.medications.mu_coded_entries.size
    end
    if (patient_summary_report.procedures)
        analysis_results["procedures_present"] +=       patient_summary_report.procedures.entries.size
        analysis_results["procedures_coded"] +=         patient_summary_report.procedures.num_coded_entries
        analysis_results["procedures_mu_compliant"] +=  patient_summary_report.procedures.mu_coded_entries.size
    end
    if (patient_summary_report.procedures)
        analysis_results["vital_signs_present"] +=      patient_summary_report.vital_signs.entries.size
        analysis_results["vital_signs_coded"] +=        patient_summary_report.vital_signs.num_coded_entries
        analysis_results["vital_signs_mu_compliant"] += patient_summary_report.vital_signs.mu_coded_entries.size
    end
  end

  def prime_analysis_results
    analysis_results = {
      "number_files" => 0.0,
      "file_validation" => 0.0,
      "allergies_present" => 0.0,
      "allergies_coded" => 0.0,
      "allergies_mu_compliant" => 0.0,
      "encounters_present" => 0.0,
      "encounters_coded" => 0.0,
      "encounters_mu_compliant" => 0.0,
      "conditions_present" => 0.0,
      "conditions_coded" => 0.0,
      "conditions_mu_compliant" => 0.0,                        
      "lab_results_present" => 0.0,
      "lab_results_coded" => 0.0,
      "lab_results_mu_compliant" => 0.0,
      "immunizations_present" => 0.0,
      "immunizations_coded" => 0.0,
      "immunizations_mu_compliant" => 0.0,
      "medications_present" => 0.0,
      "medications_coded" => 0.0,
      "medications_mu_compliant" => 0.0,
      "procedures_present" => 0.0,
      "procedures_coded" => 0.0,
      "procedures_mu_compliant" => 0.0,
      "vital_signs_present" => 0.0,
      "vital_signs_coded" => 0.0,
      "vital_signs_mu_compliant" => 0.0
    }
  end

end