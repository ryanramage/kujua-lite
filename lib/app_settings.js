// default values. If you add a new field, you should modify kanso.json settings_schma as well to match
module.exports = {
    reported_date_format: "MMM hh:mm",
    facility_labels: {
        "district":  "field office",
        "districts": "field offices",
        "District":   "Field Office",
        "Districts":  "Field Offices",
        "District Name": "District Name",
        "District Contact Name": "SMO",
        "District Contact Phone": "SMO Phone",
        "District Hospital": "Field Office",
        "District Hospitals": "Field Offices",
        "District Hospital Name": "Name",
        "District Hospital Contact Name": "SMO",

        "Health Center": "District",
        "Health Centers": "Districts",
        "Health Center Name": "District Name",
        "Health Center Contact": "District Contact",
        "Health Center Contact Name": "District Contact Name",
        "Health Center Contact Phone": "District Contact Phone",

        "clinic": "reporting unit",
        "clinics": "reporting units",
        "Clinic": "Reporting Unit",
        "Clinics": "Reporting Units",
        "Clinic Name": "Reporting Unit Name",
        "Clinic Contact": "Reporting Unit",
        "From": "From",
        "Clinic Contact Name": "Reporting Unit Contact Name",
        "Clinic Contact Phone": "Reporting Unit Contact Phone",
        "RC Code": "RU Code",
        "Facility": "Facility"
    },
    "kujua-reporting": {
        "forms": [
            {"code":"VPD", "reporting_freq":"week"}
        ]
    }
};