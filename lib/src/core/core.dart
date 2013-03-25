part of grits_shared;

Math.Random random = new Math.Random();

String newGuid_short() => ((1 + random.nextInt(0x10000)) | 0).toRadixString(16);

String newGuid() => "${newGuid_short()}${newGuid_short()}"
                    "-${newGuid_short()}-${newGuid_short()}-${newGuid_short()}-"
                    "${newGuid_short()}${newGuid_short()}${newGuid_short()}";


