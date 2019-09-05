
PANDOC = pandoc

TEXSRC = \
    history.tex \
    acknowledgment.tex \
    license.tex \
    genomic_files.tex \
    genomic_gblup.tex \
    genomic_gwas.tex \
    genomic_qc.tex \
    genomic_start.tex \
    genomic_tuning.tex \
    installation_availability.tex \
    installation_editor.tex \
    installation_env.tex \
    installation_linux.tex \
    installation_start.tex \
    installation_windows.tex \
    introduction_about.tex \
    introduction_condition.tex \
    introduction_difference.tex \
    introduction_short.tex \
    largescale_issues.tex \
    largescale_pcg.tex \
    largescale_reliability.tex \
    largescale_reml.tex \
    largescale_start.tex \
    mrode_c03ex031_animal_model.tex \
    mrode_c03ex032_sire_model.tex \
    mrode_c03ex033_reduced_animal_model.tex \
    mrode_c03ex034_animal_model_with_groups.tex \
    mrode_c04ex041_repeatability_model.tex \
    mrode_c04ex042_common_environment.tex \
    mrode_c05ex051_mt_equal_design.tex \
    mrode_c05ex052_mt_missing.tex \
    mrode_c05ex053_mt_unequal_design.tex \
    mrode_c05ex054_mt_no_covariance.tex \
    mrode_c07ex071_maternal.tex \
    mrode_c08ex081_social_interaction.tex \
    mrode_c09ex091_fixed_regression.tex \
    mrode_c09ex092_random_regression.tex \
    mrode_c10ex102_marker_information.tex \
    mrode_c10ex103_qtl.tex \
    mrode_c11ex111_fixed_snp.tex \
    mrode_c11ex112_mixed_snp.tex \
    mrode_c11ex113_gblup.tex \
    mrode_c11ex115_polygenic.tex \
    mrode_c11ex116_ssgblup.tex \
    mrode_c12ex121_dominance.tex \
    mrode_c12ex123_dominance_inverse.tex \
    mrode_c13ex131_threshold.tex \
    mrode_c13ex132_threshold_linear.tex \
    mrode_start.tex \
    quicktour_fixed.tex \
    quicktour_mixed.tex \
    quicktour_mt.tex \
    quicktour_ssgblup.tex \
    quicktour_start.tex \
    references.tex \
    renum_norenum.tex \
    renum_advanced.tex \
    renum_basic.tex \
    renum_genomic.tex \
    renum_mt.tex \
    renum_pedigree.tex \
    renum_start.tex \
    vc_advanced_aireml.tex \
    vc_advanced_gs.tex \
    vc_aireml.tex \
    vc_gs.tex

HTMLSRC = \
    history.html \
    acknowledgment.html \
    license.html \
    genomic_files.html \
    genomic_gblup.html \
    genomic_gwas.html \
    genomic_qc.html \
    genomic_start.html \
    genomic_tuning.html \
    installation_availability.html \
    installation_editor.html \
    installation_env.html \
    installation_linux.html \
    installation_start.html \
    installation_windows.html \
    introduction_about.html \
    introduction_condition.html \
    introduction_difference.html \
    introduction_short.html \
    largescale_issues.html \
    largescale_pcg.html \
    largescale_reliability.html \
    largescale_reml.html \
    largescale_start.html \
    mrode_c03ex031_animal_model.html \
    mrode_c03ex032_sire_model.html \
    mrode_c03ex033_reduced_animal_model.html \
    mrode_c03ex034_animal_model_with_groups.html \
    mrode_c04ex041_repeatability_model.html \
    mrode_c04ex042_common_environment.html \
    mrode_c05ex051_mt_equal_design.html \
    mrode_c05ex052_mt_missing.html \
    mrode_c05ex053_mt_unequal_design.html \
    mrode_c05ex054_mt_no_covariance.html \
    mrode_c07ex071_maternal.html \
    mrode_c08ex081_social_interaction.html \
    mrode_c09ex091_fixed_regression.html \
    mrode_c09ex092_random_regression.html \
    mrode_c10ex102_marker_information.html \
    mrode_c10ex103_qtl.html \
    mrode_c11ex111_fixed_snp.html \
    mrode_c11ex112_mixed_snp.html \
    mrode_c11ex113_gblup.html \
    mrode_c11ex115_polygenic.html \
    mrode_c11ex116_ssgblup.html \
    mrode_c12ex121_dominance.html \
    mrode_c12ex123_dominance_inverse.html \
    mrode_c13ex131_threshold.html \
    mrode_c13ex132_threshold_linear.html \
    mrode_start.html \
    quicktour_fixed.html \
    quicktour_mixed.html \
    quicktour_mt.html \
    quicktour_ssgblup.html \
    quicktour_start.html \
    references.html \
    renum_norenum.html \
    renum_advanced.html \
    renum_basic.html \
    renum_genomic.html \
    renum_mt.html \
    renum_pedigree.html \
    renum_start.html \
    vc_advanced_aireml.html \
    vc_advanced_gs.html \
    vc_aireml.html \
    vc_gs.html \
    index.html

.PHONY: all img clean

.SUFFIXES: .tex .md .html

all: tutorial_blupf90.pdf $(HTMLSRC) img

tutorial_blupf90.pdf: tutorial_blupf90.tex $(TEXSRC)
	pdflatex -halt-on-error tutorial_blupf90
#	makeindex tutorial_blupf90
	pdflatex -halt-on-error tutorial_blupf90
	cp tutorial_blupf90.pdf pdf/

acknowledgment.tex: acknowledgment.md
	pandoc -t latex --listings -o $@ $<

.md.tex:
	pandoc -t latex --top-level-division=section --listings -o $@ $<

.md.html:
#	pandoc --mathjax -smart -s -t html --toc --toc-depth=2 --template Github.html5.txt -o $@ $<
	pandoc --mathjax -t html --toc --toc-depth=2 --template Github.html5.txt -o $@ $<
	mv $@ html/

img:
	cp -p *.png html/

clean:
	rm -f *~ *.html tutorial*.pdf *.aux *.log *.out *.toc *.idx [^t]*.tex pdf/*.pdf html/*.html html/*.png
