version 1.0

import "wdl-common/wdl/workflows/backend_configuration/backend_configuration.wdl" as BackendConfiguration
import "family.wdl" as FamilyWorkflow
import "wdl-common/wdl/tasks/organize_outputs.wdl" as OrganizeOutputs

workflow HumanWGS_wrapper {
    input {
        Family family

        File ref_map_file

        String deepvariant_version = "1.6.1"
        File? custom_deepvariant_model_tar

        String pharmcat_version = "2.15.4"
        Int pharmcat_min_coverage = 10

        String phenotypes = "HP:0000001"
        File? tertiary_map_file

        Int? glnexus_mem_gb
        Int? pbsv_call_mem_gb

        Boolean gpu = false

        # Backend configuration
        String backend
        String? zones
        String? gpuType
        String? container_registry
        String? cpu_platform
        Boolean preemptible = true
        Int? pbmm2_align_wgs_override_mem_gb
        Int? merge_bam_stats_override_mem_gb
        Int? hiphase_override_mem_gb
        Int? pbstarphase_diplotype_override_mem_gb
        Int? pbsv_discover_override_mem_gb
        String? debug_version

        # Wrapper workflow inputs
        String workflow_outputs_bucket
    }

    String workflow_name = "HumanWGS"
    String workflow_version = "v2.1.1"

    call BackendConfiguration.backend_configuration {
        input:
            backend = backend,
            zones = zones,
            gpuType = gpuType,
            container_registry = container_registry,
            default_container_registry = "quay.io/pacbio",
            cpu_platform = cpu_platform
    }

    RuntimeAttributes default_runtime_attributes = if preemptible then backend_configuration.spot_runtime_attributes else backend_configuration.on_demand_runtime_attributes

    call FamilyWorkflow.humanwgs_family as humanwgs_family {
        input:
            family = family,
            ref_map_file = ref_map_file,
            deepvariant_version = deepvariant_version,
            custom_deepvariant_model_tar = custom_deepvariant_model_tar,
            pharmcat_version = pharmcat_version,
            pharmcat_min_coverage = pharmcat_min_coverage,
            phenotypes = phenotypes,
            tertiary_map_file = tertiary_map_file,
            glnexus_mem_gb = glnexus_mem_gb,
            pbsv_call_mem_gb = pbsv_call_mem_gb,
            gpu = gpu,
            backend = backend,
            zones = zones,
            gpuType = gpuType,
            container_registry = container_registry,
            cpu_platform = cpu_platform,
            preemptible = preemptible,
            pbmm2_align_wgs_override_mem_gb = pbmm2_align_wgs_override_mem_gb,
            merge_bam_stats_override_mem_gb = merge_bam_stats_override_mem_gb,
            hiphase_override_mem_gb = hiphase_override_mem_gb,
            pbstarphase_diplotype_override_mem_gb = pbstarphase_diplotype_override_mem_gb,
            pbsv_discover_override_mem_gb = pbsv_discover_override_mem_gb,
            debug_version = debug_version
    }

    # Each workflow_output_name is at the same index as the corresponding array of workflow_output_files
    Array[String] output_stats_file = [humanwgs_family.stats_file] # !StringCoercion

    # bam stats
    Array[String] output_bam_stats = humanwgs_family.bam_stats # !StringCoercion
    Array[String] output_read_length_plot = humanwgs_family.read_length_plot # !StringCoercion
    Array[String] output_read_quality_plot = select_all(humanwgs_family.read_quality_plot) # !StringCoercion

    # merged, haplotagged alignments
    Array[String] output_merged_haplotagged_bam = humanwgs_family.merged_haplotagged_bam # !StringCoercion
    Array[String] output_mapq_distribution_plot = humanwgs_family.mapq_distribution_plot # !StringCoercion
    Array[String] output_mg_distribution_plot = humanwgs_family.mg_distribution_plot # !StringCoercion

    # mosdepth outputs
    Array[String] output_mosdepth_summary = humanwgs_family.mosdepth_summary # !StringCoercion
    Array[String] output_mosdepth_region_bed = humanwgs_family.mosdepth_region_bed # !StringCoercion
    Array[String] output_mosdepth_depth_distribution_plot = humanwgs_family.mosdepth_depth_distribution_plot # !StringCoercion

    # phasing stats
    Array[String] output_phase_stats = humanwgs_family.phase_stats # !StringCoercion
    Array[String] output_phase_blocks = humanwgs_family.phase_blocks # !StringCoercion
    Array[String] output_phase_haplotags = humanwgs_family.phase_haplotags # !StringCoercion

    # cpg_pileup outputs
    Array[String] output_cpg_combined_bed = select_all(humanwgs_family.cpg_combined_bed) # !StringCoercion
    Array[String] output_cpg_hap1_bed = select_all(humanwgs_family.cpg_hap1_bed) # !StringCoercion
    Array[String] output_cpg_hap2_bed = select_all(humanwgs_family.cpg_hap2_bed) # !StringCoercion
    Array[String] output_cpg_combined_bw = select_all(humanwgs_family.cpg_combined_bw) # !StringCoercion
    Array[String] output_cpg_hap1_bw = select_all(humanwgs_family.cpg_hap1_bw) # !StringCoercion
    Array[String] output_cpg_hap2_bw = select_all(humanwgs_family.cpg_hap2_bw) # !StringCoercion

    # sv outputs
    Array[String] output_phased_sv_vcf = humanwgs_family.phased_sv_vcf # !StringCoercion

    # small variant outputs
    Array[String] output_phased_small_variant_vcf = humanwgs_family.phased_small_variant_vcf # !StringCoercion
    Array[String] output_small_variant_gvcf = humanwgs_family.small_variant_gvcf # !StringCoercion

    # small variant stats
    Array[String] output_small_variant_stats = humanwgs_family.small_variant_stats # !StringCoercion
    Array[String] output_bcftools_roh_out = humanwgs_family.bcftools_roh_out # !StringCoercion
    Array[String] output_bcftools_roh_bed = humanwgs_family.bcftools_roh_bed # !StringCoercion
    Array[String] output_snv_distribution_plot = humanwgs_family.snv_distribution_plot # !StringCoercion
    Array[String] output_indel_distribution_plot = humanwgs_family.indel_distribution_plot # !StringCoercion

    # trgt outputs
    Array[String] output_phased_trgt_vcf = humanwgs_family.phased_trgt_vcf # !StringCoercion
    Array[String] output_trgt_spanning_reads = humanwgs_family.trgt_spanning_reads # !StringCoercion
    Array[String] output_trgt_coverage_dropouts = humanwgs_family.trgt_coverage_dropouts # !StringCoercion

    # paraphase outputs
    Array[String] output_paraphase_output_json = humanwgs_family.paraphase_output_json # !StringCoercion
    Array[String] output_paraphase_realigned_bam = humanwgs_family.paraphase_realigned_bam # !StringCoercion
    Array[String] output_paraphase_vcfs = select_all(humanwgs_family.paraphase_vcfs) # !StringCoercion

    # per sample cnv outputs
    Array[String] output_cnv_vcf = humanwgs_family.cnv_vcf # !StringCoercion
    Array[String] output_cnv_copynum_bedgraph = humanwgs_family.cnv_copynum_bedgraph # !StringCoercion
    Array[String] output_cnv_depth_bw = humanwgs_family.cnv_depth_bw # !StringCoercion
    Array[String] output_cnv_maf_bw = humanwgs_family.cnv_maf_bw # !StringCoercion

    # PGx outputs
    Array[String] output_pbstarphase_json = humanwgs_family.pbstarphase_json # !StringCoercion
    Array[String] output_pharmcat_match_json = select_all(humanwgs_family.pharmcat_match_json) # !StringCoercion
    Array[String] output_pharmcat_phenotype_json = select_all(humanwgs_family.pharmcat_phenotype_json) # !StringCoercion
    Array[String] output_pharmcat_report_html = select_all(humanwgs_family.pharmcat_report_html) # !StringCoercion
    Array[String] output_pharmcat_report_json = select_all(humanwgs_family.pharmcat_report_json) # !StringCoercion

    # joint call outputs
    Array[String] output_joint_small_variants_vcf = select_all([humanwgs_family.joint_small_variants_vcf]) # !StringCoercion
    Array[String] output_joint_sv_vcf = select_all([humanwgs_family.joint_sv_vcf]) # !StringCoercion
    Array[String] output_joint_trgt_vcf = select_all([humanwgs_family.joint_trgt_vcf]) # !StringCoercion

    # tertiary analysis outputs
    Array[String] output_pedigree = select_all([humanwgs_family.pedigree]) # !StringCoercion
    Array[String] output_tertiary_small_variant_filtered_vcf = select_all([humanwgs_family.tertiary_small_variant_filtered_vcf]) # !StringCoercion
    Array[String] output_tertiary_small_variant_filtered_tsv = select_all([humanwgs_family.tertiary_small_variant_filtered_tsv]) # !StringCoercion
    Array[String] output_tertiary_small_variant_compound_het_vcf = select_all([humanwgs_family.tertiary_small_variant_compound_het_vcf]) # !StringCoercion
    Array[String] output_tertiary_small_variant_compound_het_tsv = select_all([humanwgs_family.tertiary_small_variant_compound_het_tsv]) # !StringCoercion
    Array[String] output_tertiary_sv_filtered_vcf = select_all([humanwgs_family.tertiary_sv_filtered_vcf]) # !StringCoercion
    Array[String] output_tertiary_sv_filtered_tsv = select_all([humanwgs_family.tertiary_sv_filtered_tsv]) # !StringCoercion

    Map[String, Array[String]] workflow_data_outputs_pre_upload = {
        "stats_file": output_stats_file,
        "bam_stats": output_bam_stats,
        "read_length_plot": output_read_length_plot,
        "read_quality_plot": output_read_quality_plot,
        "merged_haplotagged_bam": output_merged_haplotagged_bam,
        "mapq_distribution_plot": output_mapq_distribution_plot,
        "mg_distribution_plot": output_mg_distribution_plot,
        "mosdepth_summary": output_mosdepth_summary,
        "mosdepth_region_bed": output_mosdepth_region_bed,
        "mosdepth_depth_distribution_plot": output_mosdepth_depth_distribution_plot,
        "phase_stats": output_phase_stats,
        "phase_blocks": output_phase_blocks,
        "phase_haplotags": output_phase_haplotags,
        "cpg_combined_bed": output_cpg_combined_bed,
        "cpg_hap1_bed": output_cpg_hap1_bed,
        "cpg_hap2_bed": output_cpg_hap2_bed,
        "cpg_combined_bw": output_cpg_combined_bw,
        "cpg_hap1_bw": output_cpg_hap1_bw,
        "cpg_hap2_bw": output_cpg_hap2_bw,
        "phased_sv_vcf": output_phased_sv_vcf,
        "phased_small_variant_vcf": output_phased_small_variant_vcf,
        "small_variant_gvcf": output_small_variant_gvcf,
        "small_variant_stats": output_small_variant_stats,
        "bcftools_roh_out": output_bcftools_roh_out,
        "bcftools_roh_bed": output_bcftools_roh_bed,
        "snv_distribution_plot": output_snv_distribution_plot,
        "indel_distribution_plot": output_indel_distribution_plot,
        "phased_trgt_vcf": output_phased_trgt_vcf,
        "trgt_spanning_reads": output_trgt_spanning_reads,
        "trgt_coverage_dropouts": output_trgt_coverage_dropouts,
        "paraphase_output_json": output_paraphase_output_json,
        "paraphase_realigned_bam": output_paraphase_realigned_bam,
        "paraphase_vcfs": output_paraphase_vcfs,
        "cnv_vcf": output_cnv_vcf,
        "cnv_copynum_bedgraph": output_cnv_copynum_bedgraph,
        "cnv_depth_bw": output_cnv_depth_bw,
        "cnv_maf_bw": output_cnv_maf_bw,
        "pbstarphase_json": output_pbstarphase_json,
        "pharmcat_match_json": output_pharmcat_match_json,
        "pharmcat_phenotype_json": output_pharmcat_phenotype_json,
        "pharmcat_report_html": output_pharmcat_report_html,
        "pharmcat_report_json": output_pharmcat_report_json,
        "joint_small_variants_vcf": output_joint_small_variants_vcf,
        "joint_sv_vcf": output_joint_sv_vcf,
        "joint_trgt_vcf": output_joint_trgt_vcf,
        "pedigree": output_pedigree,
        "tertiary_small_variant_filtered_vcf": output_tertiary_small_variant_filtered_vcf,
        "tertiary_small_variant_filtered_tsv": output_tertiary_small_variant_filtered_tsv,
        "tertiary_small_variant_compound_het_vcf": output_tertiary_small_variant_compound_het_vcf,
        "tertiary_small_variant_compound_het_tsv": output_tertiary_small_variant_compound_het_tsv,
        "tertiary_sv_filtered_vcf": output_tertiary_sv_filtered_vcf,
        "tertiary_sv_filtered_tsv": output_tertiary_sv_filtered_tsv,
    }


    # We use the same output names as above but target the _index files, so that the indices are written alongside the VCFs
    Array[String] output_merged_haplotagged_bam_index = humanwgs_family.merged_haplotagged_bam_index # !StringCoercion
    Array[String] output_mosdepth_region_bed_index = humanwgs_family.mosdepth_region_bed_index # !StringCoercion
    Array[String] output_cpg_combined_bed_index = select_all(humanwgs_family.cpg_combined_bed_index) # !StringCoercion
    Array[String] output_cpg_hap1_bed_index = select_all(humanwgs_family.cpg_hap1_bed_index) # !StringCoercion
    Array[String] output_cpg_hap2_bed_index = select_all(humanwgs_family.cpg_hap2_bed_index) # !StringCoercion
    Array[String] output_phased_sv_vcf_index = humanwgs_family.phased_sv_vcf_index # !StringCoercion
    Array[String] output_phased_small_variant_vcf_index = humanwgs_family.phased_small_variant_vcf_index # !StringCoercion
    Array[String] output_small_variant_gvcf_index = humanwgs_family.small_variant_gvcf_index # !StringCoercion
    Array[String] output_phased_trgt_vcf_index = humanwgs_family.phased_trgt_vcf_index # !StringCoercion
    Array[String] output_trgt_spanning_reads_index = humanwgs_family.trgt_spanning_reads_index # !StringCoercion
    Array[String] output_paraphase_realigned_bam_index = humanwgs_family.paraphase_realigned_bam_index # !StringCoercion
    Array[String] output_cnv_vcf_index = humanwgs_family.cnv_vcf_index # !StringCoercion
    Array[String] output_joint_small_variants_vcf_index = select_all([humanwgs_family.joint_small_variants_vcf_index]) # !StringCoercion
    Array[String] output_joint_sv_vcf_index = select_all([humanwgs_family.joint_sv_vcf_index]) # !StringCoercion
    Array[String] output_joint_trgt_vcf_index = select_all([humanwgs_family.joint_trgt_vcf_index]) # !StringCoercion
    Array[String] output_tertiary_small_variant_filtered_vcf_index = select_all([humanwgs_family.tertiary_small_variant_filtered_vcf_index]) # !StringCoercion
    Array[String] output_tertiary_small_variant_compound_het_vcf_index = select_all([humanwgs_family.tertiary_small_variant_compound_het_vcf_index]) # !StringCoercion
    Array[String] output_tertiary_sv_filtered_vcf_index = select_all([humanwgs_family.tertiary_sv_filtered_vcf_index]) # !StringCoercion

    Map[String, Array[String]] workflow_index_outputs_pre_upload = {
        "merged_haplotagged_bam": output_merged_haplotagged_bam_index,
        "mosdepth_region_bed": output_mosdepth_region_bed_index,
        "cpg_combined_bed": output_cpg_combined_bed_index,
        "cpg_hap1_bed": output_cpg_hap1_bed_index,
        "cpg_hap2_bed": output_cpg_hap2_bed_index,
        "phased_sv_vcf": output_phased_sv_vcf_index,
        "phased_small_variant_vcf": output_phased_small_variant_vcf_index,
        "small_variant_gvcf": output_small_variant_gvcf_index,
        "phased_trgt_vcf": output_phased_trgt_vcf_index,
        "trgt_spanning_reads": output_trgt_spanning_reads_index,
        "paraphase_realigned_bam": output_paraphase_realigned_bam_index,
        "cnv_vcf": output_cnv_vcf_index,
        "joint_small_variants_vcf": output_joint_small_variants_vcf_index,
        "joint_sv_vcf": output_joint_sv_vcf_index,
        "joint_trgt_vcf": output_joint_trgt_vcf_index,
        "tertiary_small_variant_filtered_vcf": output_tertiary_small_variant_filtered_vcf_index,
        "tertiary_small_variant_compound_het_vcf": output_tertiary_small_variant_compound_het_vcf_index,
        "tertiary_sv_filtered_vcf": output_tertiary_sv_filtered_vcf_index,
    }

    call OrganizeOutputs.create_timestamp {
        input:
            runtime_attributes = default_runtime_attributes
    }

    call OrganizeOutputs.organize_outputs as organize_data_outputs {
        input:
            identifier = family.family_id,
            workflow_outputs_pre_upload = workflow_data_outputs_pre_upload,
            timestamp = create_timestamp.timestamp,
            workflow_name = workflow_name,
            workflow_version = workflow_version,
            output_bucket = workflow_outputs_bucket,
            backend = backend,
            runtime_attributes = default_runtime_attributes
    }

    call OrganizeOutputs.organize_outputs as organize_index_outputs {
        input:
            identifier = family.family_id,
            workflow_outputs_pre_upload = workflow_index_outputs_pre_upload,
            timestamp = create_timestamp.timestamp,
            workflow_name = workflow_name,
            workflow_version = workflow_version,
            output_bucket = workflow_outputs_bucket,
            backend = backend,
            runtime_attributes = default_runtime_attributes
    }

    Map[String, Array[String]] data_outputs = read_json(organize_data_outputs.output_manifest_json)
    Map[String, Array[String]] index_outputs = read_json(organize_index_outputs.output_manifest_json)

    output {
        Array[String] sample_ids = humanwgs_family.sample_ids

        Array[File] stats_file = data_outputs["stats_file"] # !FileCoercion
        Array[File] bam_stats = data_outputs["bam_stats"] # !FileCoercion
        Array[File] read_length_plot = data_outputs["read_length_plot"] # !FileCoercion
        Array[File] read_quality_plot = data_outputs["read_quality_plot"] # !FileCoercion

        Array[String] stat_num_reads = humanwgs_family.stat_num_reads
        Array[String] stat_read_length_mean = humanwgs_family.stat_read_length_mean
        Array[String] stat_read_length_median = humanwgs_family.stat_read_length_median
        Array[String] stat_read_quality_mean = humanwgs_family.stat_read_quality_mean
        Array[String] stat_read_quality_median = humanwgs_family.stat_read_quality_median

        Array[File] merged_haplotagged_bam = data_outputs["merged_haplotagged_bam"] # !FileCoercion
        Array[File] merged_haplotagged_bam_index = index_outputs["merged_haplotagged_bam"] # !FileCoercion

        Array[String] stat_mapped_read_count = humanwgs_family.stat_mapped_read_count
        Array[String] stat_mapped_percent = humanwgs_family.stat_mapped_percent

        Array[File] mapq_distribution_plot = data_outputs["mapq_distribution_plot"] # !FileCoercion
        Array[File] mg_distribution_plot = data_outputs["mg_distribution_plot"] # !FileCoercion
        Array[File] mosdepth_summary = data_outputs["mosdepth_summary"] # !FileCoercion
        Array[File] mosdepth_region_bed = data_outputs["mosdepth_region_bed"] # !FileCoercion
        Array[File] mosdepth_region_bed_index = index_outputs["mosdepth_region_bed"] # !FileCoercion
        Array[File] mosdepth_depth_distribution_plot = data_outputs["mosdepth_depth_distribution_plot"] # !FileCoercion

        Array[String] stat_mean_depth = humanwgs_family.stat_mean_depth
        Array[String] inferred_sex = humanwgs_family.inferred_sex

        Array[File] phase_stats = data_outputs["phase_stats"] # !FileCoercion
        Array[File] phase_blocks = data_outputs["phase_blocks"] # !FileCoercion
        Array[File] phase_haplotags = data_outputs["phase_haplotags"] # !FileCoercion

        Array[String] stat_phased_basepairs = humanwgs_family.stat_phased_basepairs
        Array[String] stat_phase_block_ng50 = humanwgs_family.stat_phase_block_ng50

        Array[File] cpg_combined_bed = data_outputs["cpg_combined_bed"] # !FileCoercion
        Array[File] cpg_combined_bed_index = index_outputs["cpg_combined_bed"] # !FileCoercion
        Array[File] cpg_hap1_bed = data_outputs["cpg_hap1_bed"] # !FileCoercion
        Array[File] cpg_hap1_bed_index = index_outputs["cpg_hap1_bed"] # !FileCoercion
        Array[File] cpg_hap2_bed = data_outputs["cpg_hap2_bed"] # !FileCoercion
        Array[File] cpg_hap2_bed_index = index_outputs["cpg_hap2_bed"] # !FileCoercion
        Array[File] cpg_combined_bw = data_outputs["cpg_combined_bw"] # !FileCoercion
        Array[File] cpg_hap1_bw = data_outputs["cpg_hap1_bw"] # !FileCoercion
        Array[File] cpg_hap2_bw = data_outputs["cpg_hap2_bw"] # !FileCoercion

        Array[String] stat_cpg_hap1_count = humanwgs_family.stat_cpg_hap1_count
        Array[String] stat_cpg_hap2_count = humanwgs_family.stat_cpg_hap2_count
        Array[String] stat_cpg_combined_count = humanwgs_family.stat_cpg_combined_count

        Array[File] phased_sv_vcf = data_outputs["phased_sv_vcf"] # !FileCoercion
        Array[File] phased_sv_vcf_index = index_outputs["phased_sv_vcf"] # !FileCoercion

        Array[String] stat_sv_DUP_count = humanwgs_family.stat_sv_DUP_count
        Array[String] stat_sv_DEL_count = humanwgs_family.stat_sv_DEL_count
        Array[String] stat_sv_INS_count = humanwgs_family.stat_sv_INS_count
        Array[String] stat_sv_INV_count = humanwgs_family.stat_sv_INV_count
        Array[String] stat_sv_BND_count = humanwgs_family.stat_sv_BND_count

        Array[File] phased_small_variant_vcf = data_outputs["phased_small_variant_vcf"] # !FileCoercion
        Array[File] phased_small_variant_vcf_index = index_outputs["phased_small_variant_vcf"] # !FileCoercion
        Array[File] small_variant_gvcf = data_outputs["small_variant_gvcf"] # !FileCoercion
        Array[File] small_variant_gvcf_index = index_outputs["small_variant_gvcf"] # !FileCoercion
        Array[File] small_variant_stats = data_outputs["small_variant_stats"] # !FileCoercion
        Array[File] bcftools_roh_out = data_outputs["bcftools_roh_out"] # !FileCoercion
        Array[File] bcftools_roh_bed = data_outputs["bcftools_roh_bed"] # !FileCoercion

        Array[String] stat_small_variant_SNV_count = humanwgs_family.stat_small_variant_SNV_count
        Array[String] stat_small_variant_INDEL_count = humanwgs_family.stat_small_variant_INDEL_count
        Array[String] stat_small_variant_TSTV_ratio = humanwgs_family.stat_small_variant_TSTV_ratio
        Array[String] stat_small_variant_HETHOM_ratio = humanwgs_family.stat_small_variant_HETHOM_ratio

        Array[File] snv_distribution_plot = data_outputs["snv_distribution_plot"] # !FileCoercion
        Array[File] indel_distribution_plot = data_outputs["indel_distribution_plot"] # !FileCoercion
        Array[File] phased_trgt_vcf = data_outputs["phased_trgt_vcf"] # !FileCoercion
        Array[File] phased_trgt_vcf_index = index_outputs["phased_trgt_vcf"] # !FileCoercion
        Array[File] trgt_spanning_reads = data_outputs["trgt_spanning_reads"] # !FileCoercion
        Array[File] trgt_spanning_reads_index = index_outputs["trgt_spanning_reads"] # !FileCoercion
        Array[File] trgt_coverage_dropouts = data_outputs["trgt_coverage_dropouts"] # !FileCoercion

        Array[String] stat_trgt_genotyped_count = humanwgs_family.stat_trgt_genotyped_count
        Array[String] stat_trgt_uncalled_count = humanwgs_family.stat_trgt_uncalled_count

        Array[File] paraphase_output_json = data_outputs["paraphase_output_json"] # !FileCoercion
        Array[File] paraphase_realigned_bam = data_outputs["paraphase_realigned_bam"] # !FileCoercion
        Array[File] paraphase_realigned_bam_index = index_outputs["paraphase_realigned_bam"] # !FileCoercion
        Array[File] paraphase_vcfs = data_outputs["paraphase_vcfs"] # !FileCoercion
        Array[File] cnv_vcf = data_outputs["cnv_vcf"] # !FileCoercion
        Array[File] cnv_vcf_index = index_outputs["cnv_vcf"] # !FileCoercion
        Array[File] cnv_copynum_bedgraph = data_outputs["cnv_copynum_bedgraph"] # !FileCoercion
        Array[File] cnv_depth_bw = data_outputs["cnv_depth_bw"] # !FileCoercion
        Array[File] cnv_maf_bw = data_outputs["cnv_maf_bw"] # !FileCoercion

        Array[String] stat_cnv_DUP_count = humanwgs_family.stat_cnv_DUP_count
        Array[String] stat_cnv_DEL_count = humanwgs_family.stat_cnv_DEL_count
        Array[String] stat_cnv_DUP_sum = humanwgs_family.stat_cnv_DUP_sum
        Array[String] stat_cnv_DEL_sum = humanwgs_family.stat_cnv_DEL_sum

        Array[File] pbstarphase_json = data_outputs["pbstarphase_json"] # !FileCoercion
        Array[File] pharmcat_match_json = data_outputs["pharmcat_match_json"] # !FileCoercion
        Array[File] pharmcat_phenotype_json = data_outputs["pharmcat_phenotype_json"] # !FileCoercion
        Array[File] pharmcat_report_html = data_outputs["pharmcat_report_html"] # !FileCoercion
        Array[File] pharmcat_report_json = data_outputs["pharmcat_report_json"] # !FileCoercion
        Array[File] joint_small_variants_vcf = data_outputs["joint_small_variants_vcf"] # !FileCoercion
        Array[File] joint_small_variants_vcf_index = index_outputs["joint_small_variants_vcf"] # !FileCoercion
        Array[File] joint_sv_vcf = data_outputs["joint_sv_vcf"] # !FileCoercion
        Array[File] joint_sv_vcf_index = index_outputs["joint_sv_vcf"] # !FileCoercion
        Array[File] joint_trgt_vcf = data_outputs["joint_trgt_vcf"] # !FileCoercion
        Array[File] joint_trgt_vcf_index = index_outputs["joint_trgt_vcf"] # !FileCoercion
        Array[File] pedigree = data_outputs["pedigree"] # !FileCoercion
        Array[File] tertiary_small_variant_filtered_vcf = data_outputs["tertiary_small_variant_filtered_vcf"] # !FileCoercion
        Array[File] tertiary_small_variant_filtered_vcf_index = index_outputs["tertiary_small_variant_filtered_vcf"] # !FileCoercion
        Array[File] tertiary_small_variant_filtered_tsv = data_outputs["tertiary_small_variant_filtered_tsv"] # !FileCoercion
        Array[File] tertiary_small_variant_compound_het_vcf = data_outputs["tertiary_small_variant_compound_het_vcf"] # !FileCoercion
        Array[File] tertiary_small_variant_compound_het_vcf_index = index_outputs["tertiary_small_variant_compound_het_vcf"] # !FileCoercion
        Array[File] tertiary_small_variant_compound_het_tsv = data_outputs["tertiary_small_variant_compound_het_tsv"] # !FileCoercion
        Array[File] tertiary_sv_filtered_vcf = data_outputs["tertiary_sv_filtered_vcf"] # !FileCoercion
        Array[File] tertiary_sv_filtered_vcf_index = index_outputs["tertiary_sv_filtered_vcf"] # !FileCoercion
        Array[File] tertiary_sv_filtered_tsv = data_outputs["tertiary_sv_filtered_tsv"] # !FileCoercion

        String humanwgs_family_workflow_name = humanwgs_family.workflow_name
        String humanwgs_family_worfklow_version = humanwgs_family.workflow_version
    }

    parameter_meta {
        workflow_outputs_bucket: {help: "Path to the bucket where the workflow outputs will be stored"}
    }
}
