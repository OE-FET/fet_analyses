# FET-Analyses

MATLAB scripts to load, plot, and analyze FET sweep data.

## Installation

Download the scripts from github, for instance with:
```
$ git clone https://github.com/OE-FET/FET-Analyses
```

## Usage
Use `FETDataRead` to read transfer and output curves saved by the Testing Rig or ESR setup. Since the two file formats a differnt, `FETDataRead` will search through the column headers to identify the file type ('transfer' or 'output') and possible linear and saturation sweep data. `FETDataRead` returns a MATLAB structure containing the stepped voltages (e.g., drain voltage steps in a transfer curve) as `data.Vstep`, the sweep type as `data.type` and the actual data as `data.x`, `data.Is`, `data.Id` and `data.Ig`.

Use `TransferDataPlot` and `OutputDataPlot` to plot the FET data structure returned by `FETDataRead`. The direction of hysteresis will be indicated by arrows.

<p float="centre">
  <img src="examples/transfer_plot_log.png" width="400" />
  <img src="examples/transfer_sqrt_log.png" width="400" /> 
</p>

Use `MobilityVsVg` and `MobilityCalc` to calculate gate-voltage dependent and independent mobilities, respectivey. In addtion to the FET data structure, a argument `pars` containing the FET parameters (i.e., channel length and width, dielectric constant, ...) must be provided. If any of the arguments is missing, the user will be asked to provide them.
