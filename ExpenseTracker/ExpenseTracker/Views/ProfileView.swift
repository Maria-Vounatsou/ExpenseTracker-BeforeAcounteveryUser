import SwiftUI
import CoreData

struct ProfileView: View {
    @Binding var presentSideMenu: Bool
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var dataManager: DataManager // To access the logout function
    @AppStorage("isUserSignedIn") private var isUserSignedIn: Bool = true // To update login state
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: -95) {
                    profileViewModel.selectedColor
                        .frame(height: 95)
                        .edgesIgnoringSafeArea(.top)

                    HStack {
                        Button {
                            presentSideMenu.toggle()
                        } label: {
                            Image(systemName: "list.bullet.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)

                    Text("Profile")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.top, 100)

                    Spacer().frame(height: 80)

                    VStack(alignment: .center, spacing: 30) {
                        Spacer()

                        ZStack(alignment: .bottomTrailing) {
                            if let profileImage = profileViewModel.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .overlay(
                                        Circle()
                                            .stroke(profileViewModel.selectedColor.opacity(0.5), lineWidth: 6)
                                    )
                                    .clipShape(Circle())
                            } else {
                                Image(uiImage: UIImage(named: "defaultProfileImage")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(profileViewModel.selectedColor.opacity(0.5), lineWidth: 6)
                                    )
                                    .clipShape(Circle())
                            }

                            Button(action: {
                                showImagePicker = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(profileViewModel.selectedColor)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .padding(4)
                            }
                            .offset(x: -5, y: -5)
                        }

                        Text("User Name")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)

                        Spacer()

                        VStack {
                            ColorPicker("Customize the app to your preferences", selection: $profileViewModel.selectedColor)
                                .onChange(of: profileViewModel.selectedColor) { oldColor, newColor in
                                    profileViewModel.saveColor(newColor)
                                }

                            Rectangle()
                                .fill(profileViewModel.selectedColor)
                                .frame(height: 100)
                                .cornerRadius(10)
                                .padding()
                        }

                        Button(action: {
                            profileViewModel.selectedColor = Color.new
                            profileViewModel.saveColor(Color.new)
                        }) {
                            Text("Reset to Default Color")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(profileViewModel.selectedColor)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.new, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)

                        // Logout Button
                        Button(action: {
                            print("Log Out button tapped")
                            
                            // Call the logout function and update isUserSignedIn
                            if dataManager.logOutUser() {
                                isUserSignedIn = false
                                print("User logged out and isUserSignedIn set to false.")
                            } else {
                                print("Logout failed.")
                            }
                        }) {
                            Text("Log Out")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(20)
                }
                .padding(-10)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $profileViewModel.profileImage)
            }
            .onChange(of: profileViewModel.profileImage) {
                if let newImage = profileViewModel.profileImage {
                    print("New image assigned to profileViewModel.profileImage.")
                    profileViewModel.saveProfileImage(newImage)
                }
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(presentSideMenu: .constant(false))
            .environmentObject(ProfileViewModel(context: PersistenceController.preview.container.viewContext))
    }
}
