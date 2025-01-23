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

### Licensing
```
MIT License

Copyright (c) 2025, Thomas Pirenne

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```