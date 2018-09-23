# RiscV_Verilog

RiscV_verilog is a student project created o teste the RiscV ISA, here i have implemetended a very simple hert RiscV

## Getting Started

To teste and possible deploy on FPGA you will need the Quartus Primer and ModelSim Lite version will work fine. After that just clone the repository and import the *.v files in one Verilog project.

Some times the ram module (Intel IP RAM) have some problems to import in the project so maybe you will have to to create your own is very simple, just rementer to set the follow options.

* Do not register the output Q
* Set riscV_victor.hex as memory initiation file
* The output must be 8 bits
* Has at least 16k of memory

### Prerequisites

Install Quatus Primer Lite and ModelSim from Intel [Site](https://fpgasoftware.intel.com/?edition=lite)

Is import have the RiscV Toolchain from ![Github-RiscVtoolchain](https://github.com/riscv/riscv-gnu-toolchain), when building the toolchain remember to run the build script build-rv32ima.sh

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [RiscV](https://github.com/riscv/riscv-gnu-toolchain) - The ISA used

## Authors

* **Victor Lacerda** - *Initial work* - [VictorGerin](https://github.com/VictorGerin)

## License

This project is licensed under the GNU License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* All members of RiscV project and there awesome manual
