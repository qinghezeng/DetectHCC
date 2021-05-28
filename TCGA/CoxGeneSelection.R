# install.packages("pec")
# install.packages("survival")

library(pec)
library(survival)
library(rms)

# Paths

in_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed"
out_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap"

data <- as.data.frame(read.csv(paste(out_path, "data_fpkm_clusters_survival_filtered-sangro_median_consensus_km_euclidean_3.csv",
                                               sep = "\\"), sep="\t", row.names = 1))

data <- data[!is.na(data$OS_MONTHS), c(-4, -5)]
gsub("-", ".", colnames(data)) # replace "-" with "." for the gene names

sangro_filtered = TRUE

if (sangro_filtered) {
  sangro_genes <- read.csv(paste(in_path, "Sangro_Table2_GeneList.csv",sep = "\\"), sep="\t", row.names = NULL, header=FALSE)
  sangro_genes[1,] <- "CD274"
  sangro_genes <- sangro_genes[-6,] #drop "CCL3"
  
  data <- data[,sangro_genes]
  
  # datas = "filtered-sangro"
}


formula = Surv(time=data[,"OS_MONTHS"], event=data[,"OS_STATUS"])

# Inflammatory signature
selectCox(formula = Surv(OS_MONTHS, OS_STATUS)~CD274+CD8A+LAG3+STAT1, data, rule = "aic")
fastbw(cph(Surv(OS_MONTHS, OS_STATUS)~CD274+CD8A+LAG3+STAT1,data = data),rule="aic",type="total")

# Gajewski 13-Gene Inflammatory signature
selectCox(formula = Surv(OS_MONTHS, OS_STATUS)~CCL2+CCL4+CD8A+CXCL10+CXCL9+GZMK+HLA.DMA+HLA.DMB+HLA.DOA
          +HLA.DOB+ICOS+IRF1, data, rule = "aic")
fastbw(cph(Surv(OS_MONTHS, OS_STATUS)~CCL2+CCL4+CD8A+CXCL10+CXCL9+GZMK+HLA.DMA+HLA.DMB+HLA.DOA+HLA.DOB
           +ICOS+IRF1,data = data),rule="aic",type="total")

# 6-Gene Interferon Gamma signature
selectCox(formula = Surv(OS_MONTHS, OS_STATUS)~CXCL10+CXCL9+HLA.DRA+IDO1+IFNG+STAT1, data, rule = "aic")
fastbw(cph(Surv(OS_MONTHS, OS_STATUS)~CXCL10+CXCL9+HLA.DRA+IDO1+IFNG+STAT1,data = data),rule="aic",type="total")

# short list
selectCox(formula = Surv(OS_MONTHS, OS_STATUS)~CD274+CD8A+LAG3+STAT1+CCL2+CCL4+CXCL10+CXCL9+GZMK+HLA.DMA
          +HLA.DMB+HLA.DOA+HLA.DOB+ICOS+IRF1+HLA.DRA+IDO1+IFNG+CCL5+CD27+CXCR6+CD276+PDCD1LG2+TIGIT+CCR5
          +CXCL11+GZMA+PRF1, data, rule = "aic")
fastbw(cph(Surv(OS_MONTHS, OS_STATUS)~CD274+CD8A+LAG3+STAT1+CCL2+CCL4+CXCL10+CXCL9+GZMK+HLA.DMA+HLA.DMB
           +HLA.DOA+HLA.DOB+ICOS+IRF1+HLA.DRA+IDO1+IFNG+CCL5+CD27+CXCR6+CD276+PDCD1LG2+TIGIT+CCR5+CXCL11
           +GZMA+PRF1,data = data),rule="aic",type="individual") # type=c("residual", "individual", "total")

# # full list or std-filtered list did not converge
# fastbw(cph(Surv(OS_MONTHS, OS_STATUS)~A2M+ADM+ALDOA+ALDOC+ANGPTL4+API5+APLNR+APOE+APOL6+AQP9+ARG1+ARG2+ATF3+B2M+BAD+BAMBI+BAX+BCL2L1+BID+BIRC3+BIRC5+BMP2+BNIP3L+BNIP3+C1QA+C1QB+C2+C5+C7+CBLC+CCL14+CCL18+CCL19+CCL20+CCL21+CCL2+CCL5+CCNB1+CCND1+CCND2+CCNE1+CD14+CD276+CD27+CD2+CD36+CD3D+CD40+CD44+CD4+CD68+CD74+CD79A+CD7+CDC20+CDH1+CDH2+CDKN1A+CDKN1C+CEBPB+CES3+CLEC14A+CNTFR+CPA3+CTAG1B+CTNNB1+CTSS+CXCL10+CXCL12+CXCL13+CXCL14+CXCL16+CXCL1+CXCL2+CXCL5+CXCL6+CXCL9+CXCR4+DDB2+DKK1+DPP4+DTX3L+DUSP1+DUSP5+EGR1+EIF4EBP1+EIF5AL1+ENO1+EPCAM+ERBB2+F2RL1+FADD+FBP1+FCGR3B+FCGRT+FLNB+FSTL3+GBP1+GBP2+GHR+GIMAP4+GLUD1+GLUL+GOT1+GOT2+GPSM3+GZMA+GZMH+H2AFX+HDAC11+HES1+HIF1A+HLA.A+HLA.B+HLA.C+HLA.DMA+HLA.DMB+HLA.DPA1+HLA.DPB1+HLA.DQA1+HLA.DQA2+HLA.DQB1+HLA.DRA+HLA.DRB1+HLA.DRB5+HLA.E+HLA.F+HMGA1+HMGB1+HNF1A+HRAS+HSD11B1+ICAM1+ICAM3+IER3+IFI27+IFI35+IFI6+IFIT1+IFIT2+IFIT3+IFITM1+IFITM2+IFNAR1+IFNGR1+IFNGR2+IGF2R+IKBKG+IL1RN+IL22RA1+IL2RG+IL32+IL6R+IRF1+IRF3+IRF7+IRF9+ISG15+ITGA6+ITGB2+ITPK1+JAG1+JAK1+LAMB3+LDHA+LDHB+LGALS9+LRRC32+LTB+LY96+LYZ+MAGEA12+MAGEA1+MAGEA3+MAGEC2+MARCO+MET+MGMT+MICA+MMP7+MMP9+MRC1+MX1+MYC+MYD88+NDUFA4L2+NFIL3+NFKB2+NFKBIA+NFKBIE+NKG7+NT5E+OAS1+OAS2+OASL+P4HA1+PARP12+PCK2+PC+PDGFA+PDGFRB+PDZK1IP1+PGPEP1+PIK3R1+PIK3R2+PLA1A+PLA2G2A+PLOD2+PPARG+PSMB10+PSMB5+PSMB8+PSMB9+PVR+RELA+RELB+RELN+RIPK2+RORC+RPL23+RPL7A+S100A8+S100A9+SERPINA1+SERPINH1+SFXN1+SGK1+SHC2+SIRPA+SLC16A1+SLC1A5+SLC7A5+SOCS1+SPP1+SREBF1+STAT1+STAT2+STAT3+TAP1+TAP2+TAPBPL+TAPBP+TDO2+TGFB1+TGFBR2+THBS1+THY1+TICAM1+TMEM140+TNFRSF10B+TNFRSF14+TNFRSF1A+TNFRSF1B+TNFSF10+TPI1+TPM1+TPSAB1+TREM2+TWF1+TYMP+TYMS+UBA7+UBE2C+UBE2T+VCAM1+VEGFB+VTCN1+WNT3A, data = data), rule="aic", type="individual")
