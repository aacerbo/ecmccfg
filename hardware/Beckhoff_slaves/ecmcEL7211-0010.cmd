#-d /**
#-d   \brief hardware script for EL7211-0010
#-d   \details EL7211-0010 Servo terminal with OCT feedback
#-d   \author Anders Sandstroem
#-d   \file
#-d   \note SDOS
#-d   \param [out] SDO 0x1011:01 --> 1684107116 \b reset
#-d */

#- ###########################################################
#- ############ Information:
#-  Description: EL7211-0010 Servo terminal with OCT feedback
#-
#-  Note: The sync mode can not be written to in newer firmwares:
#-        (0x1C32,0x1,0x1C33,0x1). So then these lines below needs
#-        to be removed or commented out.
#-        The log will then show error like:
#-           EtherCAT ERROR 0-46: SDO download 0x1C32:01 (2 bytes) aborted.
#-           EtherCAT ERROR 0-46: SDO abort message 0x06090030: "Value range of parameter exceeded".
#-           EtherCAT ERROR 0-46: SDO configuration failed.
#-
#- ###########################################################

epicsEnvSet("ECMC_EC_HWTYPE"             "EL7211-0010")
epicsEnvSet("ECMC_EC_VENDOR_ID"          "0x2")
epicsEnvSet("ECMC_EC_PRODUCT_ID"         "0x1c2b3052")

ecmcConfigOrDie "Cfg.EcSlaveVerify(0,${ECMC_EC_SLAVE_NUM},${ECMC_EC_VENDOR_ID},${ECMC_EC_PRODUCT_ID})"

#- ############  Reset terminal
ecmcConfigOrDie "Cfg.EcWriteSdo(${ECMC_EC_SLAVE_NUM},0x1011,0x1,1684107116,4)"

#- ############  read electronic nameplate
ecmcConfigOrDie "Cfg.EcWriteSdo(${ECMC_EC_SLAVE_NUM},0x8008,0x1,1,1)"
ecmcConfigOrDie "Cfg.EcWriteSdo(${ECMC_EC_SLAVE_NUM},0x8008,0x2,1,1)"
ecmcConfigOrDie "Cfg.EcWriteSdo(${ECMC_EC_SLAVE_NUM},0x8008,0x3,1,1)"

#- ############  set velocity loop parameters
#- TODO: For some strange reason, those two paramters are read from the motor, but seem not to take effect
#- Velocity loop integral time = 50
ecmcConfigOrDie "Cfg.EcWriteSdo(${ECMC_EC_SLAVE_NUM},0x8010,0x14,50,4)"
#- Velocity loop proportianal gain = 50
ecmcConfigOrDie "Cfg.EcWriteSdo(${ECMC_EC_SLAVE_NUM},0x8010,0x15,50,4)"

ecmcConfigOrDie "Cfg.EcAddEntryComplete(${ECMC_EC_SLAVE_NUM},${ECMC_EC_VENDOR_ID},${ECMC_EC_PRODUCT_ID},1,2,0x1600,0x7010,0x01,16,CONTROL)"
ecmcConfigOrDie "Cfg.EcAddEntryComplete(${ECMC_EC_SLAVE_NUM},${ECMC_EC_VENDOR_ID},${ECMC_EC_PRODUCT_ID},1,2,0x1601,0x7010,0x06,32,1,VELOCITY_SETPOINT)"
ecmcConfigOrDie "Cfg.EcAddEntryComplete(${ECMC_EC_SLAVE_NUM},${ECMC_EC_VENDOR_ID},${ECMC_EC_PRODUCT_ID},2,3,0x1a00,0x6000,0x11,32,POSITION)"
ecmcConfigOrDie "Cfg.EcAddEntryComplete(${ECMC_EC_SLAVE_NUM},${ECMC_EC_VENDOR_ID},${ECMC_EC_PRODUCT_ID},2,3,0x1a01,0x6010,0x01,16,STATUS)"
ecmcConfigOrDie "Cfg.EcAddEntryComplete(${ECMC_EC_SLAVE_NUM},${ECMC_EC_VENDOR_ID},${ECMC_EC_PRODUCT_ID},2,3,0x1a02,0x6010,0x07,32,VELOCITY)"

#- ############ Distributed clocks config EL7201:

#- NOTE important the sync 1 period needs to be 0!
ecmcConfigOrDie "Cfg.EcSlaveConfigDC(${ECMC_EC_SLAVE_NUM},0x700,1000000,500000,0,0)"
ecmcConfigOrDie "Cfg.EcAddSdo(${ECMC_EC_SLAVE_NUM},0x8011,0x11,1000,4)"
ecmcConfigOrDie "Cfg.EcSlaveConfigWatchDog(${ECMC_EC_SLAVE_NUM},1000,10000)"

#- Cycle time SM2
ecmcConfigOrDie "Cfg.EcAddSdo(${ECMC_EC_SLAVE_NUM},0x1C32,0x2,1000000,4)"
#- Cycle time SM3
ecmcConfigOrDie "Cfg.EcAddSdo(${ECMC_EC_SLAVE_NUM},0x1C33,0x2,1000000,4)"
