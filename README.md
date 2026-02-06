# Granger Causality Scalability

Granger causality analysis (GCA) has been widely used in neuroscience reasearch to shed light onto brain dynamics. It is widely accepted that such analyses are suited to limited amount of interacting entities. The scale of neurophysiological data is much larger than what current GCA can handle, forcing researchers to reduce data dimensionality. Previous literature shows that such a manipulation affects the results of the analyses. We conducted experiments to precisely identify the scale limitations of such analyses, with respect to the method employed. This repository contains the implementation of these experiments.

### Results
The end results of the analyses are structured in form of figures. Those figures are presented in the manuscript related to this work. The figure panels and table resources are provided in `data/results/`.

### Implementation
The analysis is made up of two parts:
1. **Causal data generation**: causality simulation and estimation with different scaling parameters.
2. **Data processing**: data analysis and formatting into figures.

### Usage
To replicate the results, the scripts can be run as follow.

1. Clone this repository.
2. Obtain the software required to run the experiments: [Matlab](https://www.mathworks.com/products/matlab.html) (2024a or above)
3. Open the cloned repository with Matlab. `startup.m` should be at its root.
4. Generate or download the simulation data:
    - Generate it by executing the script `>> run_data_generation` (cumulated runtime of over a month)
    - [Download](https://1drv.ms/f/c/ecd141ed7214ac19/EgxWtlRyF7lEnCCjWo8OzjsBO6Dw1H_tVprT_qGuphpSWg) prerun data.
5. Process data by executing the script `>> run_data_processing` (cumulated runtime of a few minutes).

### References
1. M. Morf, A. Vieira, D. T. L. Lee and T. Kailath, "Recursive Multichannel Maximum Entropy Spectral Estimation," *IEEE Transactions on Geoscience Electronics*, vol. 16, no. 2, pp. 85-94, (**1978**). [doi:10.1109/TGE.1978.294569](https://doi.org/10.1109/TGE.1978.294569)
2. Tibshirani, Robert. “Regression Shrinkage and Selection via the Lasso.” *Journal of the Royal Statistical Society*. Series B (Methodological), vol. 58, no. 1, pp. 267–88, (**1996**). [JSTOR/2346178](http://www.jstor.org/stable/2346178)
3. Baccala, L.A. and Sameshima, K. Partial Directed Coherence: A New Concept in Neural Structure Determination. Biological Cybernetics, 84, 463-474, (**2001**). [doi:10.1007/PL00007990](https://doi.org/10.1007/pl00007990)
4. Barnett, Lionel, and Anil K Seth. “The MVGC multivariate Granger causality toolbox: a new approach to Granger-causal inference.” *Journal of neuroscience methods* vol. 223 (**2014**): 50-68. [doi:10.1016/j.jneumeth.2013.10.018](https://doi.org/10.1016/j.jneumeth.2013.10.018)
5. Peiyang, Li et al., "Robust brain causality network construction based on Bayesian multivariate autoregression", *Biomedical Signal Processing and Control*, Volume 58, (**2020**). [doi:10.1016/j.bspc.2020.101864](https://doi.org/10.1016/j.bspc.2020.101864)
6. Liu, Ke et al. “Robust Bayesian Estimation of EEG-Based Brain Causality Networks.” *IEEE transactions on bio-medical engineering* vol. 70,6 (**2023**): 1879-1890. [doi:10.1109/TBME.2022.3231627](https://doi.org/10.1109/TBME.2022.3231627) 


