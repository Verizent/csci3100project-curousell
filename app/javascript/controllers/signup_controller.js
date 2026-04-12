import { Controller } from "@hotwired/stimulus"

const FACULTY_DEPARTMENTS = {
  "Faculty of Arts": [
    "Department of Anthropology",
    "Department of Chinese Language and Literature",
    "Department of Cultural and Religious Studies",
    "Department of English",
    "Department of Fine Arts",
    "Department of History",
    "Department of Japanese Studies",
    "Department of Linguistics and Modern Languages",
    "Department of Music",
    "Department of Philosophy",
    "Department of Translation"
  ],
  "Faculty of Business Administration": [
    "The School of Accountancy",
    "Department of Decisions, Operations and Technology",
    "Department of Finance",
    "School of Hotel and Tourism Management",
    "Department of Management",
    "Department of Marketing"
  ],
  "Faculty of Education": [
    "Department of Curriculum and Instruction",
    "Department of Educational Administration and Policy",
    "Department of Educational Psychology",
    "Department of Sports Science and Physical Education"
  ],
  "Faculty of Engineering": [
    "Department of Biomedical Engineering",
    "Department of Computer Science and Engineering",
    "Department of Electronic Engineering",
    "Department of Information Engineering",
    "Department of Mechanical and Automation Engineering",
    "Department of Systems Engineering and Engineering Management"
  ],
  "Faculty of Law": [
    "Faculty of Law"
  ],
  "Faculty of Medicine": [
    "Department of Anaesthesia and Intensive Care",
    "Department of Anatomical and Cellular Pathology",
    "School of Biomedical Sciences",
    "Department of Chemical Pathology",
    "School of Chinese Medicine",
    "Department of Clinical Oncology",
    "Department of Imaging and Interventional Radiology",
    "Department of Medicine and Therapeutics",
    "Department of Microbiology",
    "The Nethersole School of Nursing",
    "Department of Obstetrics and Gynaecology",
    "Department of Ophthalmology and Visual Sciences",
    "Department of Orthopaedics and Traumatology",
    "Department of Otorhinolaryngology, Head and Neck Surgery",
    "Department of Paediatrics",
    "School of Pharmacy",
    "Department of Psychiatry",
    "The Jockey Club School of Public Health and Primary Care",
    "Department of Surgery"
  ],
  "Faculty of Science": [
    "Department of Chemistry",
    "Department of Earth and Environmental Sciences",
    "School of Life Sciences",
    "Department of Mathematics",
    "Department of Physics",
    "Department of Statistics and Data Science"
  ],
  "Faculty of Social Sciences": [
    "School of Architecture",
    "Department of Economics",
    "Department of Geography and Resource Management",
    "School of Governance and Policy Science",
    "School of Journalism and Communication",
    "Department of Psychology",
    "Department of Social Work",
    "Department of Sociology"
  ],
  "Zhizhen School of Interdisciplinary Mathematical Sciences": [
    "Zhizhen School of Interdisciplinary Mathematical Sciences"
  ],
  "Other Academic Units": [
    "Postgraduate",
    "Teacher/Lecturer",
    "Researcher",
    "Staff",
    "Other"
  ]
}

// Connects to data-controller="signup"
export default class extends Controller {
  static targets = ["termsCheckbox", "submitBtn", "modal", "facultySelect", "departmentSelect"]

  connect() {
    this.submitBtnTarget.disabled = true
    this.departmentSelectTarget.disabled = true
  }

  toggleSubmit() {
    this.submitBtnTarget.disabled = !this.termsCheckboxTarget.checked
  }

  filterDepartments() {
    const selected = Array.from(this.facultySelectTarget.selectedOptions).map(o => o.value)
    const deptSelect = this.departmentSelectTarget

    deptSelect.innerHTML = ""

    if (selected.length === 0) {
      deptSelect.disabled = true
      return
    }

    deptSelect.disabled = false
    selected.forEach(faculty => {
      const departments = FACULTY_DEPARTMENTS[faculty] || []
      const group = document.createElement("optgroup")
      group.label = faculty
      departments.forEach(dept => {
        const option = document.createElement("option")
        option.value = dept
        option.textContent = dept
        group.appendChild(option)
      })
      deptSelect.appendChild(group)
    })
  }

  openModal() {
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  closeModal() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
}
