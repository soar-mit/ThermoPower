within ThermoPower.customModel.Examples;

model LumpedCondenser_test
  "Test for LumpedCondenser model"
  LumpedCondenser lumpedCondenser1(p = 1e5, Vtot = 10)  annotation(
    Placement(transformation(origin = {-18, 52}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SourceMassFlow sourceMassFlow1(redeclare package Medium = ThermoPower.Water.StandardWater, T = 423.15, h = 2736444, use_T = false, w0 = 100) annotation(
    Placement(transformation(origin = {-78, 82}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SinkPressure sinkPressure1(T = 383.15, h = 417503, p0(displayUnit = "bar") = 1e5, use_T = false) annotation(
    Placement(transformation(origin = {-78, 20}, extent = {{10, -10}, {-10, 10}})));
  ThermoPower.Water.Flow1DFV2ph InletPart1(A = 0.2, DynamicMomentum = false, FFtype = ThermoPower.Choices.Flow1D.FFtypes.Colebrook, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Steam, L = 3, N = 3, Nt = 1, dpnom(displayUnit = "Pa") = 15000, e = 0.00015, hstartin = 2736444, hstartout = 2736444, noInitialPressure = false, omega = 1.57, p(displayUnit = "Pa"), pstart(displayUnit = "bar") = 1e5, wnf = 0.5, wnm = 0.1, wnom = 100) annotation(
    Placement(transformation(origin = {-46, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 180)));
  ThermoPower.Water.Flow1DFV2ph OutletPart1(A = 0.2, DynamicMomentum = false, FFtype = ThermoPower.Choices.Flow1D.FFtypes.Colebrook, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Liquid, L = 3, N = 3, Nt = 1, dpnom(displayUnit = "Pa") = 15000, e = 0.00015, hstartin = 417503, hstartout = 417503, noInitialPressure = false, omega = 1.57, p(displayUnit = "Pa"), pstart(displayUnit = "bar") = 1e5, wnf = 0.5, wnm = 0.1, wnom = 100) annotation(
    Placement(transformation(origin = {-46, 20}, extent = {{-10, -10}, {10, 10}}, rotation = -180)));
  inner ThermoPower.System system(allowFlowReversal = false, initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
    Placement(transformation(origin = {78, 84}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.customModel.LumpedCondenser lumpedCondenser2(Vtot = 10, p = 1e5) annotation(
    Placement(transformation(origin = {-18, -46}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SourceMassFlow sourceMassFlow2(redeclare package Medium = ThermoPower.Water.StandardWater, T = 423.15, h = 2404054, use_T = false, w0 = 100) annotation(
    Placement(transformation(origin = {-78, -16}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SinkPressure sinkPressure2(T = 383.15, h = 417503, p0(displayUnit = "bar") = 1e5, use_T = false) annotation(
    Placement(transformation(origin = {-78, -78}, extent = {{10, -10}, {-10, 10}})));
  ThermoPower.Water.Flow1DFV2ph InletPart2(A = 0.2, DynamicMomentum = false, FFtype = ThermoPower.Choices.Flow1D.FFtypes.Colebrook, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Steam, L = 3, N = 3, Nt = 1, dpnom(displayUnit = "Pa") = 15000, e = 0.00015, hstartin = 2404054, hstartout = 2404054, noInitialPressure = false, omega = 1.57, p(displayUnit = "Pa"), pstart(displayUnit = "bar") = 1e5, wnf = 0.5, wnm = 0.1, wnom = 100) annotation(
    Placement(transformation(origin = {-46, -16}, extent = {{10, -10}, {-10, 10}}, rotation = 180)));
  ThermoPower.Water.Flow1DFV2ph OutletPart2(A = 0.2, DynamicMomentum = false, FFtype = ThermoPower.Choices.Flow1D.FFtypes.Colebrook, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Liquid, L = 3, N = 3, Nt = 1, dpnom(displayUnit = "Pa") = 15000, e = 0.00015, hstartin = 417503, hstartout = 417503, noInitialPressure = false, omega = 1.57, p(displayUnit = "Pa"), pstart(displayUnit = "bar") = 1e5, wnf = 0.5, wnm = 0.1, wnom = 100) annotation(
    Placement(transformation(origin = {-46, -78}, extent = {{-10, -10}, {10, 10}}, rotation = -180)));
equation
  connect(sourceMassFlow1.flange, InletPart1.infl) annotation(
    Line(points = {{-68, 82}, {-56, 82}}, color = {0, 0, 255}));
  connect(InletPart1.outfl, lumpedCondenser1.steamIn) annotation(
    Line(points = {{-36, 82}, {-18, 82}, {-18, 62}}, color = {0, 0, 255}));
  connect(lumpedCondenser1.waterOut, OutletPart1.infl) annotation(
    Line(points = {{-18, 42}, {-18, 20}, {-36, 20}}, color = {0, 0, 255}));
  connect(OutletPart1.outfl, sinkPressure1.flange) annotation(
    Line(points = {{-56, 20}, {-68, 20}}, color = {0, 0, 255}));
  connect(sourceMassFlow2.flange, InletPart2.infl) annotation(
    Line(points = {{-68, -16}, {-56, -16}}, color = {0, 0, 255}));
  connect(InletPart2.outfl, lumpedCondenser2.steamIn) annotation(
    Line(points = {{-36, -16}, {-18, -16}, {-18, -36}}, color = {0, 0, 255}));
  connect(lumpedCondenser2.waterOut, OutletPart2.infl) annotation(
    Line(points = {{-18, -56}, {-18, -78}, {-36, -78}}, color = {0, 0, 255}));
  connect(OutletPart2.outfl, sinkPressure2.flange) annotation(
    Line(points = {{-56, -78}, {-68, -78}}, color = {0, 0, 255}));
  annotation(
    experiment(StartTime = 0, StopTime = 10, Tolerance = 1e-06, Interval = 0.02),
  Diagram(graphics = {Text(origin = {7, 89}, extent = {{-21, 7}, {21, -7}}, textString = "Case1"), Text(origin = {7, -7}, extent = {{-21, 7}, {21, -7}}, textString = "Case2")}),
  Documentation(info="<html>
    <p> Case1: Superheat steam -> Saturated liquid.
    <p> Case2: Saturated steam -> Saturated liquid.
</html>"));
end LumpedCondenser_test;