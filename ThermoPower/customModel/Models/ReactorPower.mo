within ThermoPower.customModel.Models;

model ReactorPower "Point Kinetics Equations with 6 delayed neutron groups"
  // ============================================================
  //  Power parameters
  // ============================================================
  parameter SI.Power P0 "Nominal (initial) thermal power [W]";
  parameter Boolean usePKE = false "Enable point kinetics";
  parameter Boolean useTf = false "Enable Fuel temperature feedback" annotation(
    Dialog(enable = usePKE));
  parameter Boolean useTm = false "Enable Moderator temperature feedback" annotation(
    Dialog(enable = usePKE));
  parameter Boolean useTc = false "Enable Coolant temperature feedback" annotation(
    Dialog(enable = usePKE));
  parameter Boolean useRhoExt = false "Enable external reactivity insertion" annotation(
    Dialog(enable = usePKE));
  parameter Boolean useXe = false "Enable Xe-135 dynamics" annotation(
    Dialog(enable = usePKE));
  // ============================================================
  //  Neutron kinetics parameters
  // ============================================================
  parameter Real Lambda = 0.0003712 "Prompt neutron generation time [s]" annotation(
    Dialog(enable = usePKE));
  //parameter Real beta_total = 0.00657 "Total delayed neutron fraction" annotation(Dialog(enable = usePKE));
  final parameter Real beta_total = sum(beta);
  parameter Real beta[6] = {0.00020, 0.00113, 0.00138, 0.00244, 0.00103, 0.00039} "Delayed neutron fractions per group" annotation(
    Dialog(enable = usePKE));
  parameter Real lambda[6] = {0.01243983, 0.03050824, 0.11143845, 0.30136834, 1.13630685, 3.01368339} "Delayed neutron precursor decay constants [1/s]" annotation(
    Dialog(enable = usePKE));
  // ============================================================
  //  Temperature feedback parameters
  // ============================================================
  parameter Real alpha_f = 0 "Fuel temperature reactivity coefficient [dk/k/K]" annotation(
    Dialog(enable = usePKE and useTf));
  parameter Real alpha_m = 0 "Moderator temperature reactivity coefficient [dk/k/K]" annotation(
    Dialog(enable = usePKE and useTm));
  parameter Real alpha_c = 0 "Coolant temperature reactivity coefficient [dk/k/K]" annotation(
    Dialog(enable = usePKE and useTc));
  parameter SI.Temperature Tf0(displayUnit="K") = 0 "Reference fuel temperature [K]" annotation(
    Dialog(enable = usePKE and useTf));
  parameter SI.Temperature Tm0(displayUnit="K") = 0 "Reference moderator temperature [K]" annotation(
    Dialog(enable = usePKE and useTm));
  parameter SI.Temperature Tc0(displayUnit="K") = 0 "Reference coolant temperature [K]" annotation(
    Dialog(enable = usePKE and useTc));
  // ============================================================
  //  Xe-135 parameters
  // ============================================================
  parameter Real lambda_I = 2.926e-5 "I-135 decay constant [1/s]" annotation(
    Dialog(group = "Xenon", enable = usePKE and useXe)); // from Theory and calculation of 135Xe concentration time evolution for the nuclear power plant CNA II
  parameter Real lambda_X = 2.106e-5 "Xe-135 decay constant [1/s]" annotation(
    Dialog(group = "Xenon", enable = usePKE and useXe)); // from Theory and calculation of 135Xe concentration time evolution for the nuclear power plant CNA II
  parameter Real gamma_I = 0.0639 "I-135 fission yield (including 135Sb and 135Te)" annotation(
    Dialog(group = "Xenon", enable = usePKE and useXe)); // from Theory and calculation of 135Xe concentration time evolution for the nuclear power plant CNA II
  parameter Real gamma_X = 0.00237 "Xe-135 direct fission yield" annotation(
    Dialog(group = "Xenon", enable = usePKE and useXe)); // from Theory and calculation of 135Xe concentration time evolution for the nuclear power plant CNA II
  parameter Real sigma_aX = 2.6e-18 "Xe-135 effective 1-group absorption XS [cm2]" annotation(
    Dialog(group = "Xenon", enable = usePKE and useXe));
  parameter Real nu = 2.43 "Neutrons per fission" annotation(
    Dialog(group = "Xenon", enable = usePKE and useXe));
  parameter Real phi0 = 5.1796e13 "Representative 1-group flux at nominal power [n/cm2/s]" annotation(Dialog(group = "Xenon", enable = usePKE and useXe));    
  final parameter Real gamma_tot = gamma_I+gamma_X "Total yield";
  final parameter Real g_I = gamma_I/gamma_tot "I-135 fraction";
  final parameter Real g_Xe = gamma_X/gamma_tot "Xe-135 fraction";
  final parameter Real R_Xe = lambda_X+sigma_aX*phi0 "Xe-135 removal rate [1/s]";
  final parameter Real R_Xe_absorb = sigma_aX*phi0/R_Xe  "absorption fraction";
  final parameter Real rho_Xe0 = -gamma_tot*R_Xe_absorb/nu "Equilibrium Xe reactivity at nominal power [dK/K]";
  // ============================================================
  //  Initialization
  // ============================================================
  parameter Real n_start = 1 "Initial relative power [-]" annotation(Dialog(tab="Initialization"));
  final parameter Real x_start=n_start/((1-R_Xe_absorb)+R_Xe_absorb*n_start) "Initial normalized Xe concentration";
  final parameter Real rho_Xe_eq0 = rho_Xe0*x_start "Initial Xe equilibrium reactivity [dK/K]";
  // ============================================================
  //  Variables
  // ============================================================
  Real n(start = n_start) "Relative neutron density (n/n0) [-]";
  Real C[6](start = {beta[i]*n_start/(Lambda*lambda[i]) for i in 1:6}) "Delayed neutron precursor concentrations";
  Real C_relative[6](each start = n_start) "Relative precursor concentration";
  Real I_normalized(start = n_start) "Normalized I-135 concentration[-]";
  Real Xe_normalized(start = x_start) "Normalized Xe-135 concentration [-]";
  Real rho_Xe "Xe reactivity, deviation from initial [dK/K]";
  SI.Power P "Absolute thermal power [W]";
  Real rho "Total reactivity [dk/k]";
  Real rho_feedback "Temperature feedback reactivity [dk/k]";
  //Real rho_ext_internal "Internal copy of external reactivity";
  //outer ThermoPower.System system "System wide properties";
  // ============================================================
  //  Connectors - Inputs
  // ============================================================
  Modelica.Blocks.Interfaces.RealInput rho_ext if usePKE and useRhoExt "External reactivity input [dk/k]" annotation(
    Placement(transformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-90, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Interfaces.RealInput Tf if usePKE and useTf "Fuel temperature input [K]" annotation(
    Placement(transformation(origin = {-60, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {-60, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Interfaces.RealInput Tm if usePKE and useTm "Moderator temperature input [K]" annotation(
    Placement(transformation(origin = {0, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {0, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Interfaces.RealInput Tc if usePKE and useTc "Coolant temperature input [K]" annotation(
    Placement(transformation(origin = {60, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {60, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  // ============================================================
  //  Connectors - Outputs
  // ============================================================
  Modelica.Blocks.Interfaces.RealOutput Power "Absolute thermal power output [W]" annotation(
    Placement(transformation(extent = {{90, -10}, {110, 10}}), iconTransformation(origin = {-10, 0}, extent = {{90, -10}, {110, 10}})));
protected
  Real Tf_internal;
  Real Tm_internal;
  Real Tc_internal;
  Real rho_ext_internal;
public
equation
// ============================================================
//  Connector handling
// ============================================================
  if usePKE and useTf then
    Tf_internal = Tf;
  else
    Tf_internal = Tf0;
  end if;

  if usePKE and useTm then
    Tm_internal = Tm;
  else
    Tm_internal = Tm0;
  end if;

  if usePKE and useTc then
    Tc_internal = Tc;
  else
    Tc_internal = Tc0;
  end if;
  
  if usePKE and useRhoExt then
    rho_ext_internal = rho_ext;
  else
    rho_ext_internal = 0;
  end if;

// ============================================================
//  Xe-135 dynamics (normalized to 1 = equilibrium with nominal power
// ============================================================
  if usePKE and useXe then
    der(I_normalized) = lambda_I*(n-I_normalized);
    der(Xe_normalized) = R_Xe*((g_Xe*n+g_I*I_normalized)-((1-R_Xe_absorb)+R_Xe_absorb*n)*Xe_normalized);
    rho_Xe = rho_Xe0*Xe_normalized-rho_Xe_eq0; // rho_Xe=0 at equilibrium
  else
    der(I_normalized) = 0.0;
    der(Xe_normalized) = 0.0;
    rho_Xe = 0.0;
  end if;

// ============================================================
//  Point kinetics
// ============================================================
  if usePKE then
    rho_feedback = alpha_f*(Tf_internal - Tf0) + alpha_m*(Tm_internal - Tm0) + alpha_c*(Tc_internal - Tc0);
    rho = rho_ext_internal + rho_feedback + rho_Xe;
    der(n) = (rho - beta_total)/Lambda*n + sum(lambda[i]*C[i] for i in 1:6);
    for i in 1:6 loop
      der(C[i]) = (beta[i]/Lambda)*n - lambda[i]*C[i];
    end for;
  else
// constant power
    rho_feedback = 0;
    rho = 0;
    n = n_start;
    for i in 1:6 loop
      C[i] = beta[i]/(Lambda*lambda[i]);
    end for;
  end if;
// ============================================================
//  Power output
// ============================================================
  P = n*P0;
  Power = P;
  for i in 1:6 loop
    C_relative[i] = C[i]/(beta[i]/(Lambda*lambda[i]));
  end for;
// ============================================================
//  Initial conditions
// ============================================================
initial equation
  //der(n) = 0;
  //for i in 1:6 loop
    //C[i] = beta[i]/(Lambda*lambda[i]);
  //end for;
  if usePKE then
    n = n_start;
    for i in 1:6 loop
      C[i] = beta[i]*n_start/(Lambda*lambda[i]);
    end for;
  end if;
  I_normalized = n_start;
  Xe_normalized = x_start;
  annotation(
    Icon(graphics = {Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-80, 80}, {80, -80}}), Text(textColor = {0, 0, 255}, extent = {{-60, 40}, {60, -40}}, textString = "Power"), Text( origin = {-60, 32},textColor = {191, 95, 0}, extent = {{-20, -80}, {20, -110}}, textString = "Tf"), Text(origin = {0, 32}, textColor = {191, 95, 0}, extent = {{-20, -80}, {20, -110}}, textString = "Tm"), Text(origin = {58, 32}, textColor = {191, 95, 0}, extent = {{-20, -80}, {20, -110}}, textString = "Tc"), Text(origin = {-114, 118}, textColor = {191, 95, 0}, extent = {{-20, -80}, {20, -110}}, textString = "rho_ext")}),
    Documentation(info = "<HTML>
<p>Point Kinetics Equations (PKE) model with 6 delayed neutron groups.</p>

<p><b>Features:</b></p>
<ul>
<li>6-group delayed neutron precursor equations</li>
<li>External reactivity input via RealInput (can be 0)</li>
<li>Optional fuel/moderator temperature feedback:
  rho_fb = alpha_f*(Tf - Tf0) + alpha_m*(Tm - Tc0)</li>
<li> Xenon/Iodine dynamics</li>
<li>Absolute (W) and relative power outputs</li>
</ul>

<p><b>Connectors:</b></p>
<ul>
<li><tt>rho_ext</tt>: external reactivity [dk/k]</li>
<li><tt>Tf</tt>: fuel temperature [K]</li>
<li><tt>Tm</tt>: moderator temperature [K]</li>
<li><tt>Power</tt>: absolute thermal power [W]</li>
</ul>
</HTML>"),
    experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.002),
    Diagram(graphics));
end ReactorPower;