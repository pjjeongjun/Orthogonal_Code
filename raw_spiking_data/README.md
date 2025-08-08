# Data and Code Description

## 1. Spike Data – Success Trials

- memory_vp001_corrected_either_tp001_von_abt3_0_500_success_att3_500_1200  
  Firing rates of memory cells from **-500 to 1200 ms** relative to target **ONSET**.

- memory_vp001_corrected_either_tp001_von_abt3_0_500_success_abt3_0_500  
  Firing rates of memory cells from **0 to 500 ms** relative to target **OFFSET**.

- memory_vp001_corrected_either_tp001_von_abt3_0_500_success_abt3_500_1000  
  Firing rates of memory cells from **500 to 1000 ms** relative to target **OFFSET**.

- visual_vp001_corrected_either_tp001_von_att3_50_250_success_att3_500_1200  
  Firing rates of visual cells from **0 to 1200 ms** relative to target **ONSET**.

- untuned_vp001_corrected_either_tp001_von_att3_50_250_success_att3_500_1200  
  Firing rates of untuned cells from **0 to 1200 ms** relative to target **ONSET**.

## 2. Spike Data – Error Trials

- memory_vp001_corrected_either_tp001_von_abt3_0_500_error_att3_500_1200  
  Firing rates of memory cells from **-500 to 1200 ms** relative to target **ONSET**.

- memory_vp001_corrected_either_tp001_von_abt3_0_500_error_abt3_0_500  
  Firing rates of memory cells from **0 to 500 ms** relative to target **OFFSET**.

- memory_vp001_corrected_either_tp001_von_abt3_0_500_error_abt3_500_1000  
  Firing rates of memory cells from **500 to 1000 ms** relative to target **OFFSET**.

- visual_vp001_corrected_either_tp001_von_att3_50_250_error_att3_500_1200  
  Firing rates of visual cells from **0 to 1200 ms** relative to target **ONSET**.

- untuned_vp001_corrected_either_tp001_von_att3_50_250_error_att3_500_1200  
  Firing rates of untuned cells from **0 to 1200 ms** relative to target **ONSET**.

## 3. Tuning Data

- memory_tuning_vp001_corrected_either_tp001_von_abt3_0_500.mat  
  Spatial tuning of memory cells from **0 to 500 ms** after target **OFFSET**.

- visual_tuning_vp001_corrected_either_tp001_von_att3_50_250.mat  
  Spatial tuning of visual cells from **50 to 250 ms** after target **ONSET**.

## 4. Data reconstruction

- dataScript_6bins.m  
 Reformats spike data into the structure: **neuron x direction x task x time x trial**.  
 Target directions are grouped into six uniform bins, each spanning 60°.

- dataScript_pref_null.m  
 Reformats spike data into the structure: **neuron x direction x task x time x trial**.  
 Target directions are categorized as preferred, intermediate, or null; only preferred and null directions are retained.
