class DSSuportSiren extends ZombieSuperSiren;

var KFGameType KF;

simulated function SpawnTwoShots()
{
    DoShakeEffect();

	if( Level.NetMode!=NM_Client )
	{
		// Deal Actual Damage.
		if( Controller!=None && KFDoorMover(Controller.Target)!=None )
			Controller.Target.TakeDamage(-ScreamDamage*0.6,Self,Location,vect(0,0,0),ScreamDamageType);
		else HurtRadius(ScreamDamage ,ScreamRadius, ScreamDamageType, ScreamForce, Location);
	}
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local float UsedDamageAmount;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		// Or Karma actors in this case. Self inflicted Death due to flying chairs is uncool for a zombie of your stature.
		if( (Victims != self) && !Victims.IsA('FluidSurfaceInfo') && !Victims.IsA('ExtendedZCollision') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

			if (!Victims.IsA('KFHumanPawn')) // If it aint human, don't pull the vortex crap on it.
				Momentum = 0;

			if (Victims.IsA('KFGlassMover'))   // Hack for shattering in interesting ways.
			{
				UsedDamageAmount = 100000; // Siren always shatters glass
			}
			else
			{
                UsedDamageAmount = DamageAmount;
			}

		if( Victims.IsA('KFMonster') )
		{
        KF = KFGameType(Level.Game);

        if( (KFMonster(Victims).Health*10 + damageScale * UsedDamageAmount * KF.GameDifficulty) < KFMonster(Victims).HealthMax )
          Victims.TakeDamage(-damageScale * UsedDamageAmount * KF.GameDifficulty,Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(damageScale * Momentum * dir),DamageType);
        else if( KFMonster(Victims).Health < KFMonster(Victims).HealthMax )
          Victims.TakeDamage(KFMonster(Victims).Health - KFMonster(Victims).HealthMax,Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(damageScale * Momentum * dir),DamageType);
		}
		else
        Victims.TakeDamage(damageScale * UsedDamageAmount,Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(damageScale * Momentum * dir),DamageType);

            if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(UsedDamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
		}
	}
	bHurtEntry = false;
}



defaultproperties
{
	Skins(0)=FinalBlend'KF_Specimens_Trip_T.siren_hair_fb'
	Skins(1)=Texture'Magic_big_black_dick.sz.EvilSiren_diff'
	HeadScale=1.250000 
	MenuName="Support Siren"
	ScreamRadius=2500 // 700
    ScreamForce=-90000 // -150000
    RotRate=1000.000000 // 500.000000
    OffsetRate=1000.000000 // 500.000000
    ShakeTime=4.000000 // 2.000000
	MeleeDamage=25 // 13
    damageForce=10000 // 5000
    ScreamDamage=12 // 8
	GroundSpeed=200.000000 // 100.000000
    WaterSpeed=160.000000 // 80.000000
	DrawScale=1.250000 // 1.050000
	MotionDetectorThreat=4.000000 // 2.000000
}