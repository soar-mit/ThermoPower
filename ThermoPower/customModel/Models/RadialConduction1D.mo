within ThermoPower.customModel.Models;

model RadialConduction1D
  "Cylindrical (annular) tube model with Nw axial finite volumes and Nr radial nodes"
  extends Icons.MetalWall;
  import ThermoPower.Choices.CylinderFourier.NodeDistribution;
  // ============================================================
  //  Parameters
  // ============================================================
  parameter Integer Nw = 1 "Number of axial volumes";
  parameter Integer Nr = 3 "Number of radial nodes (min 2)";
  parameter Integer Nt = 1 "Number of tubes in parallel";
  parameter SI.Length L "Tube length";
  parameter SI.Length rint "Internal radius (single tube)";
  parameter SI.Length rext "External radius (single tube)";
  parameter Real rhomcm "Metal heat capacity per unit volume [J/(m3.K)]";
  parameter SI.ThermalConductivity lambda "Thermal conductivity";
  parameter NodeDistribution nodeDistribution = ThermoPower.Choices.CylinderFourier.NodeDistribution.uniform "Radial node distribution";
  parameter Boolean useHeatGen = false "Enable internal heat generation";
  parameter Real heatGenValue = 0 "Heat generation value [W/m3]" annotation(
    Dialog(enable = useHeatGen));
  parameter Boolean useExternalHeatGen = false "true: from RealInput, false: from parameter [W]" annotation(Dialog(group="External inputs", enable=useHeatGen), choices(checkBox=true));
  parameter Real axialProfile[Nw] = ones(Nw) "Relative axial power distribution (will be normalized to 1)" annotation(
  Dialog(enable = useHeatGen));
  Modelica.Blocks.Interfaces.RealInput heatGenInput if useExternalHeatGen "External heat generation input [W]"
  annotation(Placement(transformation(origin = {-100, -20}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, -20}, extent = {{-10, -10}, {10, 10}})));
  
  // ============================================================
  //  Initialisation
  // ============================================================
  parameter SI.Temperature Tstartbar = 300 "Average temperature" annotation(
    Dialog(tab = "Initialisation"));
  parameter SI.Temperature TstartInt = Tstartbar "Temperature start value at rint" annotation(
    Dialog(tab = "Initialisation"));
  parameter SI.Temperature TstartExt = Tstartbar "Temperature start value at rext" annotation(
    Dialog(tab = "Initialisation"));
  parameter Choices.Init.Options initOpt = system.initOpt "Initialisation option" annotation(
    Dialog(tab = "Initialisation"));
  // ============================================================
  //  Constants and derived parameters
  // ============================================================
  constant Real pi = Modelica.Constants.pi;
  final parameter SI.Length dz = L/Nw "Axial length per volume";
  final parameter Real normalizedAxialProfile[Nw] = axialProfile/sum(axialProfile) "Normalized axial power distribution";
  // ============================================================
  //  Variables
  // ============================================================
  // Radial geometry
  SI.Length r[Nr] "Radial node positions";
  SI.Length r_mid[Nr - 1] "Mid-point radii between adjacent nodes";
  SI.Area Ar[Nr] "Radial cross-sectional area of each shell [m2] (per unit axial length, per tube)";
  // Temperature field: T[axial, radial]
  SI.Temperature T[Nw, Nr](each start = Tstartbar) "Nodal temperatures";
  // Axial-average mean wall temperature (for diagnostics)
  SI.Temperature Tm[Nw] "Mean radial temperature per axial volume";
  Real qvol_avg "Average volumetric heat generation rate [W/m3]";
  Real qvol[Nw] "Actual volumetric heat genration rate [W/m3]";
  Modelica.Blocks.Interfaces.RealOutput Tm_avg "Average temperature [K]" annotation(Placement(transformation(origin = {-10, 20}, extent = {{-90, -10}, {-110, 10}}, rotation = -0), iconTransformation(origin = {-2, 20}, extent = {{-90, -10}, {-110, 10}}, rotation = -0)));
  Real Tmax  "Maximum temperature";
  outer ThermoPower.System system "System wide properties";
  // ============================================================
  //  Connectors
  // ============================================================
  ThermoPower.Thermal.DHTVolumes int(final N = Nw) "Internal surface" annotation(
    Placement(transformation(extent = {{-40, 20}, {40, 40}}, rotation = 0)));
  ThermoPower.Thermal.DHTVolumes ext(final N = Nw) "External surface" annotation(
    Placement(transformation(extent = {{-40, -42}, {40, -20}}, rotation = 0)));

protected
  Modelica.Blocks.Interfaces.RealInput heatGenInput_internal;

equation
  assert(rext > rint, "External radius must be greater than internal radius");
  assert(Nr >= 2, "Number of radial nodes must be at least 2");
  
// ===========================================================
//  Radial node distribution (same options as CylinderFourier)
// ===========================================================
  for i in 1:Nr loop
    if nodeDistribution == NodeDistribution.uniform then
      r[i] = rint + (rext - rint)*(i - 1)/(Nr - 1);
    elseif nodeDistribution == NodeDistribution.thickInternal then
      r[i] = rint + 1/(rext - rint)*(rint + (rext - rint)*(i - 1)/(Nr - 1) - rint)^2;
    elseif nodeDistribution == NodeDistribution.thickExternal then
      r[i] = rext - 1/(rext - rint)*(rext - (rint + (rext - rint)*(i - 1)/(Nr - 1)))^2;
    elseif nodeDistribution == NodeDistribution.thickBoth then
      if rint + (rext - rint)*(i - 1)/(Nr - 1) <= (rint + rext)/2 then
        r[i] = 2/(rext - rint)*(rint + (rext - rint)*(i - 1)/(Nr - 1) - rint)^2 + rint;
      else
        r[i] = -2/(rext - rint)*(rint + (rext - rint)*(i - 1)/(Nr - 1) - rext)^2 + rext;
      end if;
    else
      r[i] = 0;
      assert(false, "Unsupported NodeDistribution type");
    end if;
  end for;
// Mid-point radii
  for i in 1:Nr - 1 loop
    r_mid[i] = (r[i] + r[i + 1])/2;
  end for;
// Radial shell cross-sectional areas (per unit length, per tube)
  Ar[1] = pi*(r_mid[1]^2 - r[1]^2);
  for i in 2:Nr - 1 loop
    Ar[i] = pi*(r_mid[i]^2 - r_mid[i - 1]^2);
  end for;
  Ar[Nr] = pi*(r[Nr]^2 - r_mid[Nr - 1]^2);
// ===========================================================
//  Set heatGenValue
// ===========================================================
  if useExternalHeatGen then
    connect(heatGenInput, heatGenInput_internal);
    qvol_avg = heatGenInput_internal/(pi*(rext^2-rint^2)*L*Nt) "W to W/m3";
  else 
    heatGenInput_internal = 0;
    qvol_avg = heatGenValue;
  end if;
  // Assign axial distribution
  for j in 1:Nw loop
    qvol[j] = qvol_avg*Nw*normalizedAxialProfile[j];
  end for;
// ===========================================================
//  Energy balance per axial volume j, per radial node i
// ===========================================================
  for j in 1:Nw loop
// --- Connector temperatures ---
    int.T[j] = T[j, 1];
    ext.T[j] = T[j, Nr];
// --- Node i = 1  (internal boundary) ---
    rhomcm*Ar[1]*dz*Nt*der(T[j, 1]) = int.Q[j] + lambda*2*pi*r_mid[1]*dz*Nt*(T[j, 2] - T[j, 1])/(r[2] - r[1]) + qvol[j]*Ar[1]*dz*Nt;
// --- Interior nodes i = 2 .. Nr-1 ---
    for i in 2:Nr - 1 loop
      rhomcm*Ar[i]*dz*Nt*der(T[j, i]) = lambda*2*pi*r_mid[i - 1]*dz*Nt*(T[j, i - 1] - T[j, i])/(r[i] - r[i - 1]) + lambda*2*pi*r_mid[i]*dz*Nt*(T[j, i + 1] - T[j, i])/(r[i + 1] - r[i]) + qvol[j]*Ar[i]*dz*Nt;
    end for;
// --- Node i = Nr (external boundary) ---
    rhomcm*Ar[Nr]*dz*Nt*der(T[j, Nr]) = lambda*2*pi*r_mid[Nr - 1]*dz*Nt*(T[j, Nr - 1] - T[j, Nr])/(r[Nr] - r[Nr - 1]) + ext.Q[j] + qvol[j]*Ar[Nr]*dz*Nt;
// --- Mean radial temperature (area-weighted) ---
    Tm[j] = 1/(rext^2 - rint^2)*sum((T[j, i]*r[i] + T[j, i + 1]*r[i + 1])*(r[i + 1] - r[i]) for i in 1:Nr - 1);
  end for;
// --- Mean temperature for PKE purpose
  Tm_avg = sum(Tm)/Nw;
// --- Max temperature
  Tmax = max(T);
// ===========================================================
//  Initial conditions
// ===========================================================
initial equation
  if initOpt == Choices.Init.Options.noInit then
// do nothing
  elseif initOpt == Choices.Init.Options.fixedState then
    for j in 1:Nw loop
      for i in 2:Nr-1 loop
        T[j, i] = TstartInt + (TstartExt - TstartInt)*(i - 1)/(Nr - 1);
      end for;
    end for;
  elseif initOpt == Choices.Init.Options.steadyState then
    for j in 1:Nw loop
      der(T[j, 1:Nr]) = zeros(Nr);
    end for;
  elseif initOpt == Choices.Init.Options.steadyStateNoT then
// do nothing
  else
    assert(false, "Unsupported initialisation option");
  end if;
  annotation(
    Dialog(tab = "Heat Generation"),
    Icon(graphics = {Text(extent = {{-100, 60}, {-40, 20}}, textString = "Int"), Text(extent = {{-100, -20}, {-40, -60}}, textString = "Ext"), Text(textColor = {191, 95, 0}, extent = {{-138, -60}, {142, -100}}, textString = "%name")}),
    Documentation(info = "<HTML>
<p>This model solves 1D radial conduction without axial conduction.
  Internal heat generation can be provided via internal value or external source.
  Also, this model provides single area-averaged temperature for PKE purpose.
  <p> Tested in RadialConduction1D_test.
</ul>
</HTML>"),
    experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.002));
end RadialConduction1D;
