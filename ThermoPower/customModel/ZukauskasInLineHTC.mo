within ThermoPower.customModel;

model ZukauskasInLineHTC 
  "Zukauskas heat transfer correlation for in-line and square pt & pl tube bank, external cross-flow"
  extends ThermoPower.Thermal.BaseClasses.DistributedHeatTransferFV;
  
  //  Variables at nodes
  Medium.DynamicViscosity     mu[Nf]  "Dynamic viscosity";
  Medium.ThermalConductivity  k[Nf]   "Thermal conductivity";
  Medium.SpecificHeatCapacity cp[Nf]  "Specific heat at constant pressure";
  SI.PerUnit Re[Nf] "Reynolds number based on max vel. and tube OD";
  SI.PerUnit Pr[Nf] "Prandtl number (bulk)";
  Real       C_c[Nf] "Zukauskas C coefficient";
  Real       m_exp[Nf] "Zukauskas Re exponent";
  SI.PerUnit Nu[Nf] "Nusselt number";
  SI.CoefficientOfHeatTransfer gamma[Nf] "Heat transfer coefficient at nodes";
  
  //  Variables at volumes
  SI.CoefficientOfHeatTransfer gamma_vol[Nw] "Heat transfer coefficient at volumes";
  Medium.Temperature Tvol[Nw] "Fluid temperature at volumes";
  
  // Parameter for pt and pl
  parameter Real pt_OD "Pitch to diameter ratio";

equation
  assert(Nw == Nf - 1, "Number of wall volumes Nw must equal Nf - 1");
  
  // Fluid properties at the nodes
  for j in 1:Nf loop
    mu[j] = Medium.dynamicViscosity(fluidState[j]);
    k[j]  = Medium.thermalConductivity(fluidState[j]);
    cp[j] = Medium.heatCapacity_cp(fluidState[j]);
    
    // Re : v_max = v(w/o tubes)*((OD/pt)/(OD/pt-1))
    Re[j] = abs(w[j]*Dhyd/(A*mu[j]))*(pt_OD/(pt_OD-1));
    Pr[j] = cp[j]*mu[j]/k[j];
    
    (C_c[j], m_exp[j]) = ZukauskasInLineCoeffs(Re[j]);
    
    // Neglect Pr/Prw term
    Nu[j]    = C_c[j]*Re[j]^m_exp[j]*Pr[j]^0.36;
    gamma[j] = Nu[j]*k[j]/Dhyd;
  end for;
  
  // Volume-wise heat flow to wall
  for j in 1:Nw loop
    Tvol[j]      = if useAverageTemperature then (T[j] + T[j+1])/2     else T[j+1];
    gamma_vol[j] = if useAverageTemperature then (gamma[j]+gamma[j+1])/2 else gamma[j+1];
    Qw[j] = (Tw[j] - Tvol[j])*kc*omega*l*gamma_vol[j]*Nt;
  end for;
  
  annotation (
    Icon(graphics={Text(extent={{-100,-52},{100,-80}}, textString="%name")}),
    Documentation(info="<html>
<p>Zukauskas correlation for external cross-flow over an in-line tube bank,
following Incropera, <i>Fundamentals of Heat and Mass Transfer</i>, Table 7.7.</p>

<p><b>Correlation:</b> Nu = C * Re^m * Pr^0.36, with (Pr/Pr_wall)^0.25 omitted.</p>

<p><b>Setup requirements in the host Flow1DFV component:</b></p>
<ul>
<li><tt>Dhyd</tt> must be set to the <b>tube outer diameter</b> D_o</li>
<li><tt>A</tt> must be set to the <b>minimum (gap) flow area</b>, so that w/A
    yields the mass flux at maximum velocity</li>
<li><tt>omega</tt> = pi * D_o (per single tube)</li>
<li><tt>Nt</tt> = total number of tubes in the bundle</li>
</ul>

<p><b>Limitations:</b></p>
<ul>
<li>Pr/Pr_wall correction omitted (acceptable for He, single-phase gases)</li>
<li>Originally intended for bundles with N_L &ge; 20 rows; correction factor C2
    for fewer rows is not applied here</li>
<li>Re-regime transitions are noEvent if-then-else, derivative discontinuous at
    100, 1000, 2e5 (acceptable for steady or slowly varying flow)</li>
</ul>
</html>"));
end ZukauskasInLineHTC;